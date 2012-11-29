class Poems extends Backbone.Collection
  model: window.Poetry.User
  url: "/api/users"

window.Poetry.Poems = Poems
