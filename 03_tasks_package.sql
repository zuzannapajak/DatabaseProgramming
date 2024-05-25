CREATE OR REPLACE PACKAGE tasks AS
    PROCEDURE add_task(
        p_service_node_id IN tasks.service_node_id%TYPE,
        p_status IN tasks.status%TYPE,
        p_order_id IN tasks.order_id%TYPE,
        p_assignee IN tasks.assignee%TYPE,
        p_input_data IN tasks.input_data%TYPE
    );

    -- Returns true if task was deleted and false otherwise
    FUNCTION delete_task(
        p_task_id IN tasks.id%TYPE
    ) RETURN BOOLEAN;

    -- assigns the task to the specified user
    PROCEDURE assign_task(
        p_task_id IN tasks.id%TYPE,
        p_assignee IN tasks.assignee%TYPE
    );

    PROCEDURE update_task_status(
        p_task_id IN tasks.id%TYPE,
        p_new_status IN tasks.status%TYPE
    );

    -- Calculates average completion time for tasks for a given department or all tasks if p_department_id is null
   FUNCTION calculate_avg_completion_time(p_department_id IN departments.id%TYPE) RETURN NUMBER;

END tasks;

CREATE OR REPLACE PACKAGE BODY tasks AS 

    PROCEDURE add_task(
        p_service_node_id IN tasks.service_node_id%TYPE,
        p_status IN tasks.status%TYPE,
        p_order_id IN tasks.order_id%TYPE,
        p_assignee IN tasks.assignee%TYPE,
        p_input_data IN tasks.input_data%TYPE
    ) IS
    BEGIN
        INSERT INTO tasks (id, created_at, service_node_id, status, status_changed_at, order_id, assignee, input_data)
        VALUES (tasks_seq.NEXTVAL, SYSTIMESTAMP, p_service_node_id, p_status, SYSTIMESTAMP, p_order_id, p_assignee, p_input_data);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END add_task;

    FUNCTION delete_task(
        p_task_id IN tasks.id%TYPE
    ) RETURN BOOLEAN IS
    BEGIN
        DELETE FROM tasks WHERE id = p_task_id;

        -- Check if any row was deleted
        RETURN SQL%ROWCOUNT > 0;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END delete_task;

    -- assigns the task to the specified user
    PROCEDURE assign_task(
        p_task_id IN tasks.id%TYPE,
        p_assignee IN tasks.assignee%TYPE
    ) IS
    BEGIN
        UPDATE tasks
        SET assignee = p_assignee
        WHERE id = p_task_id;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END assign_task;

    PROCEDURE update_task_status(
        p_task_id IN tasks.id%TYPE,
        p_new_status IN tasks.status%TYPE
    ) IS
        invalid_status EXCEPTION;
    BEGIN
        -- Validate status
        IF p_new_status NOT IN ('to_do', 'in_progress', 'hold', 'cancelled', 'done') THEN
            RAISE invalid_status;
        END IF;

        -- Update the task's status
        UPDATE tasks
        SET status = p_new_status,
            status_changed_at = SYSTIMESTAMP
        WHERE id = p_task_id;
    EXCEPTION
        WHEN invalid_status THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20005, 'Invalid status specified.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_task_status;

    -- Calculates average completion time for tasks for a given department or all tasks if p_department_id is null
    FUNCTION calculate_avg_completion_time(p_department_id IN departments.id%TYPE) 
    RETURN NUMBER IS
        total_time NUMBER(10, 2) := 0;
        task_count INT := 0;
        task_record tasks%ROWTYPE;
        completion_time INTERVAL DAY TO SECOND;

        CURSOR task_cursor IS
            SELECT t.*
            FROM tasks t
            JOIN service_nodes sn ON sn.id = t.service_node_id
            JOIN service_steps ss ON ss.id = sn.service_step_id
            WHERE (p_department_id IS NULL OR ss.department_id = p_department_id) 
            AND t.status = 'done'
            AND t.status_changed_at IS NOT NULL
            AND t.created_at IS NOT NULL;
    BEGIN
        OPEN task_cursor;
        LOOP
            FETCH task_cursor INTO task_record;
            EXIT WHEN task_cursor%NOTFOUND;

            -- Calculate time difference in minutes
            completion_time := task_record.status_changed_at - task_record.created_at;
            total_time := total_time + EXTRACT(DAY FROM completion_time) * 1440 + EXTRACT(HOUR FROM completion_time) * 60 + EXTRACT(MINUTE FROM completion_time);

            task_count := task_count + 1;
        END LOOP;
        CLOSE task_cursor;

        IF task_count > 0 THEN
            RETURN total_time / task_count;
        ELSE
            RETURN NULL;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'An error occurred while calculating average completion time: ' || SQLERRM);
    END calculate_avg_completion_time;

END tasks;
