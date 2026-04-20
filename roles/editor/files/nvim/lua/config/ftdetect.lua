vim.filetype.add({
  filename = {
    [".env"] = "dotenv",
    ["nginx.conf"] = "nginx",
  },
  pattern = {
    [".*%.env%..*"] = "dotenv",
    [".*/nginx/.*%.conf"] = "nginx",
    [".*/sites%-available/.*"] = "nginx",
    [".*/sites%-enabled/.*"] = "nginx",
  },
})
