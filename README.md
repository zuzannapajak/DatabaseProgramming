# Database schema for running a digital agency

It is designed to allow the definition of any service as a process consisting of simple steps.
It streamlines the communication between the customer and service provider by dividing the service process into tasks, where some tasks are to be completed by customers (e.g. filling a form with preferences) and some by employees (e.g. issuing an invoice).

## Functionalities:

1. Service provider defines the offered service as a relation of interdependent steps
2. Orders can be placed for a specified service
3. On order creation appropriate tasks are inserted and assigned to proper employees depending on their department or to the customer (tasks are created based on the purchased service definition)
4. Service steps can take different input types from users, input has to be saved on task completion and it has to be accessible from tasks that depend on this step
5. Clients belong to companies to allow collaboration on tasks
