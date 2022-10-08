

# sqflite_entities

sqlite model annotations and code-generator

## motivation

https://dbdiagram.io/d/6341f49df0018a1c5fc24f90
```sql

Table "images" {
  "id" INTEGER [pk]
  "created_at" INTEGER [not null]
  "uploaded_at" INTEGER
  "file_size_bytes" INTEGER
  "is_file_uploaded" INTEGER [not null]
  "width" INTEGER [not null]
  "height" INTEGER [not null]
  "is_deleted" INTEGER [not null]
}

Table "profile" {
  "first_name" TEXT [not null]
  "last_name" TEXT [not null]
  "position" TEXT
  "profile" TEXT
  "team_name" TEXT
  "id" INTEGER [pk, increment]
  "created" INTEGER [not null, default: `now()`]
}

```

![](./docs/schema.png)

## to generate sqlite models and adapters 

run the following command:

>> fvm flutter packages pub run build_runner build --delete-conflicting-outputs   
