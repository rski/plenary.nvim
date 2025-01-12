local scan = require "plenary.scandir"
local eq = assert.are.same

local contains = function(tbl, str)
  for _, v in ipairs(tbl) do
    if v == str then
      return true
    end
  end
  return false
end

local contains_match = function(tbl, str)
  for _, v in ipairs(tbl) do
    if v:match(str) then
      return true
    end
  end
  return false
end

describe("scandir", function()
  describe("can list all files recursive", function()
    it("with cwd", function()
      local dirs = scan.scan_dir "."
      eq("table", type(dirs))
      eq(true, contains(dirs, "./CHANGELOG.md"))
      eq(true, contains(dirs, "./LICENSE"))
      eq(true, contains(dirs, "./lua/plenary/job.lua"))
      eq(false, contains(dirs, "./asdf/asdf/adsf.lua"))
    end)

    it("and callback gets called for each entry", function()
      local count = 0
      local dirs = scan.scan_dir(".", {
        on_insert = function()
          count = count + 1
        end,
      })
      eq("table", type(dirs))
      eq(true, contains(dirs, "./CHANGELOG.md"))
      eq(true, contains(dirs, "./LICENSE"))
      eq(true, contains(dirs, "./lua/plenary/job.lua"))
      eq(false, contains(dirs, "./asdf/asdf/adsf.lua"))
      eq(count, #dirs)
    end)

    it("with multiple paths", function()
      local dirs = scan.scan_dir { "./lua", "./tests" }
      eq("table", type(dirs))
      eq(true, contains(dirs, "./lua/say.lua"))
      eq(true, contains(dirs, "./lua/plenary/job.lua"))
      eq(true, contains(dirs, "./tests/plenary/scandir_spec.lua"))
      eq(false, contains(dirs, "./asdf/asdf/adsf.lua"))
    end)

    it("with hidden files", function()
      local dirs = scan.scan_dir(".", { hidden = true })
      eq("table", type(dirs))
      eq(true, contains(dirs, "./CHANGELOG.md"))
      eq(true, contains(dirs, "./lua/plenary/job.lua"))
      eq(true, contains(dirs, "./.gitignore"))
      eq(false, contains(dirs, "./asdf/asdf/adsf.lua"))
    end)

    it("with add directories", function()
      local dirs = scan.scan_dir(".", { add_dirs = true })
      eq("table", type(dirs))
      eq(true, contains(dirs, "./CHANGELOG.md"))
      eq(true, contains(dirs, "./lua/plenary/job.lua"))
      eq(true, contains(dirs, "./lua"))
      eq(true, contains(dirs, "./tests"))
      eq(false, contains(dirs, "./asdf/asdf/adsf.lua"))
    end)

    it("until depth 1 is reached", function()
      local dirs = scan.scan_dir(".", { depth = 1 })
      eq("table", type(dirs))
      eq(true, contains(dirs, "./CHANGELOG.md"))
      eq(true, contains(dirs, "./README.md"))
      eq(false, contains(dirs, "./lua"))
      eq(false, contains(dirs, "./lua/say.lua"))
      eq(false, contains(dirs, "./lua/plenary/job.lua"))
      eq(false, contains(dirs, "./asdf/asdf/adsf.lua"))
    end)

    it("until depth 1 is reached and with directories", function()
      local dirs = scan.scan_dir(".", { depth = 1, add_dirs = true })
      eq("table", type(dirs))
      eq(true, contains(dirs, "./CHANGELOG.md"))
      eq(true, contains(dirs, "./README.md"))
      eq(true, contains(dirs, "./lua"))
      eq(false, contains(dirs, "./lua/say.lua"))
      eq(false, contains(dirs, "./lua/plenary/job.lua"))
      eq(false, contains(dirs, "./asdf/asdf/adsf.lua"))
    end)

    it("until depth 2 is reached", function()
      local dirs = scan.scan_dir(".", { depth = 2 })
      eq("table", type(dirs))
      eq(true, contains(dirs, "./CHANGELOG.md"))
      eq(true, contains(dirs, "./README.md"))
      eq(true, contains(dirs, "./lua/say.lua"))
      eq(false, contains(dirs, "./lua/plenary/job.lua"))
      eq(false, contains(dirs, "./asdf/asdf/adsf.lua"))
    end)

    it("with respect_gitignore", function()
      vim.cmd ":silent !touch lua/test.so"
      local dirs = scan.scan_dir(".", { respect_gitignore = true })
      vim.cmd ":silent !rm lua/test.so"
      eq("table", type(dirs))
      eq(true, contains(dirs, "./CHANGELOG.md"))
      eq(true, contains(dirs, "./LICENSE"))
      eq(true, contains(dirs, "./lua/plenary/job.lua"))
      eq(false, contains(dirs, "./lua/test.so"))
      eq(false, contains(dirs, "./asdf/asdf/adsf.lua"))
    end)

    it("with search pattern", function()
      local dirs = scan.scan_dir(".", { search_pattern = "filetype" })
      eq("table", type(dirs))
      eq(true, contains(dirs, "./scripts/update_filetypes_from_github.lua"))
      eq(true, contains(dirs, "./lua/plenary/filetype.lua"))
      eq(true, contains(dirs, "./tests/plenary/filetype_spec.lua"))
      eq(true, contains(dirs, "./data/plenary/filetypes/base.lua"))
      eq(true, contains(dirs, "./data/plenary/filetypes/builtin.lua"))
      eq(false, contains(dirs, "./README.md"))
    end)
  end)

  describe("ls", function()
    it("works for cwd", function()
      local dirs = scan.ls "."
      eq("table", type(dirs))
      eq(true, contains_match(dirs, "CHANGELOG.md"))
      eq(true, contains_match(dirs, "LICENSE"))
      eq(true, contains_match(dirs, "README.md"))
      eq(true, contains_match(dirs, "lua"))
      eq(false, contains_match(dirs, "%.git$"))
    end)

    it("works for another directory", function()
      local dirs = scan.ls "./lua"
      eq("table", type(dirs))
      eq(true, contains_match(dirs, "luassert"))
      eq(true, contains_match(dirs, "plenary"))
      eq(true, contains_match(dirs, "say.lua"))
      eq(false, contains_match(dirs, "README.md"))
    end)

    it("works with opts.hidden for cwd", function()
      local dirs = scan.ls(".", { hidden = true })
      eq("table", type(dirs))
      eq(true, contains_match(dirs, "CHANGELOG.md"))
      eq(true, contains_match(dirs, "LICENSE"))
      eq(true, contains_match(dirs, "README.md"))
      eq(true, contains_match(dirs, "lua"))
      eq(true, contains_match(dirs, "%.git$"))
    end)
  end)
end)
