class User extends Backbone.Model
  defaults:
    email: "ed@cat.com"
    first_name: "dog"
    last_name: "cat"
    id: "-1"
    username: "cat"
    poems: []

  idAttribute: "_id"
  urlRoot : '/api/users'

window.Poetry.User = User
