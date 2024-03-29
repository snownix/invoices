# Invoices

Invoices - #1 Phoenix Invoicing SAAS

```mermaid
graph TD
    Users
        --> | Credentials | A
    P[Projects] 
        -->|Belong to| Users

    A[Auth] 
        -->|Login / Register| D{Project}
        --> P
            
    D -->| | Quotes
        --> | Belong to| Customers
    D -->| | Invoices
        --> | Belong to| Customers

    Quotes --> | Has One| IA(Invoice Address)
    Invoices --> | Has One| IA(Invoice Address)

    D -->| | Customers
        --> |Has many| CA(Customer Address)
    D -->| | Products
        --> |Belongs to| Categories
    D -->| | Categories
        -->|subcategory| Categories

    D --> Activity
    D ---> S{Settings}

    S --> Preferences
    S --> Notifications
    S --> Taxs

    style D fill:#DBB1BC

    style Activity fill:#89DAFF

    style Invoices fill:#89DAFF 
    style Products fill:#89DAFF 
    style Categories fill:#89DAFF 
    style Customers fill:#89DAFF 
    style Quotes fill:#89DAFF 
    style CA fill:#c8dc23
    style IA fill:#c8dc23
```


To start Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Enable S3 Storage

Copy the env example and modify values

```
cp .env.example .env
```

Run command to apply the env vars

```
source .env
```

Run the Phoenix server

```
mix phx.server
```

## Docs

- Docs: https://hexdocs.pm/phoenix


![Alt](https://repobeats.axiom.co/api/embed/808439c6307a26d0f72760b887e76aea4cbf51e9.svg "Repobeats analytics image")
