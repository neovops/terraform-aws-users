module "users" {
  source = "../../"

  super_admin_users = [
    "firstname1.lastname1",
    "firstname2.lastname2",
  ]
}
