import type { MyTestDirectoryFile } from "MyTestDirectory"

describe("grug-far integration (search and replace)", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("can use grug-far.nvim to search and replace in the directory of the hovered file", () => {
    cy.startNeovim({
      filename: "routes/posts.$postId/adjacent-file.txt",
    }).then((dir) => {
      // wait until text on the start screen is visible
      cy.contains("this file is adjacent-file.txt")

      cy.typeIntoTerminal("{upArrow}")
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents[
          "should-be-excluded-file.txt"
        ].name,
      )
      // close yazi and start grug-far.nvim
      cy.typeIntoTerminal("{control+g}")
      cy.contains("Grug FAR")

      // the directory we were in should be prefilled in grug-far.nvim's view
      cy.contains("testdirs")
      cy.contains("routes/posts.$postId" satisfies MyTestDirectoryFile)

      // by default, the focus is on the search field in normal mode. Type
      // something in the search field so we can see if results can be found
      cy.typeIntoTerminal("ithis")

      // maybe we don't want to make too many assertions on code we don't own
      // though, so for now we trust that it works in CI, and can verify it
      // works locally
    })
  })

  it("can search and replace, limited to selected files only", () => {
    cy.startNeovim({
      filename: "routes/posts.$postId/adjacent-file.txt",
    }).then((dir) => {
      cy.contains("this file is adjacent-file.txt")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      )

      // select the current file and the file below. There are three files in
      // this directory so two will be selected and one will be left
      // unselected
      cy.typeIntoTerminal("vj")
      cy.typeIntoTerminal("{control+g}")

      cy.typeIntoTerminal("ithis")
      cy.typeIntoTerminal("{esc}")

      // close the split on the right so we can get some more space
      cy.runExCommand({ command: "only" })

      // the selected files should be visible in the view, used as the files to
      // whitelist into the search and replace operation
      cy.contains("routes/posts.$postId/adjacent-file.txt")
      cy.contains("routes/posts.$postId/route.tsx")

      // the files in the same directory that were not selected should not be
      // visible in the view
      cy.contains("routes/posts.$postId/should-be-excluded-file.txt").should(
        "not.exist",
      )
    })
  })
})

describe("telescope integration (search)", () => {
  // https://github.com/nvim-telescope/telescope.nvim
  beforeEach(() => {
    cy.visit("/")
  })

  it("can use telescope.nvim to search in the current directory", () => {
    cy.startNeovim({
      filename: "routes/posts.$postId/adjacent-file.txt",
    }).then((dir) => {
      cy.contains("this file is adjacent-file.txt")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      )

      cy.typeIntoTerminal("{control+s}")

      cy.contains(new RegExp(`Grep in testdirs/.*?/routes/posts.\\$postId`))

      // verify this manually for now as I'm a bit scared this will be too
      // flaky
    })
  })

  it("can use telescope.nvim to search, limited to the selected files only", () => {
    cy.startNeovim({
      filename: "routes/posts.$postId/adjacent-file.txt",
    }).then((dir) => {
      cy.contains("this file is adjacent-file.txt")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      )

      // select the current file and the file below. There are three files in
      // this directory so two will be selected and one will be left
      // unselected
      cy.typeIntoTerminal("vj")
      cy.typeIntoTerminal("{control+s}")

      // telescope should be open now
      cy.contains("Grep Preview")
      cy.contains("Grep in 2 paths")

      // search for some file content. This should match
      // ../../../test-environment/routes/posts.$postId/adjacent-file.txt
      cy.typeIntoTerminal("this")

      // verify this manually for now as I'm a bit scared this will be too
      // flaky
    })
  })
})

describe("fzf-lua integration (grep)", () => {
  beforeEach(() => {
    cy.visit("/")
  })

  it("can use fzf-lua.nvim to search in the current directory", () => {
    cy.startNeovim({
      filename: "routes/posts.$postId/adjacent-file.txt",
      startupScriptModifications: ["modify_yazi_config_use_fzf_lua.lua"],
    }).then((dir) => {
      cy.contains("this file is adjacent-file.txt")
      cy.typeIntoTerminal("{upArrow}")
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      )

      cy.typeIntoTerminal("{control+s}")

      // wait for fzf-lua to be visible
      cy.contains("to Fuzzy Search")

      cy.typeIntoTerminal("this")

      // results should be visible
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents[
          "should-be-excluded-file.txt"
        ].name,
      )

      // results from outside the directory should not be visible. This
      // verifies the search is limited to the current directory
      cy.contains(dir.contents["initial-file.txt"].name).should("not.exist")
    })
  })

  it("can use fzf-lua.nvim to search, limited to the selected files only", () => {
    // https://github.com/ibhagwan/fzf-lua
    cy.startNeovim({
      filename: "routes/posts.$postId/route.tsx",
      startupScriptModifications: ["modify_yazi_config_use_fzf_lua.lua"],
    }).then((dir) => {
      // wait until the file contents are visible
      cy.contains("02c67730-6b74-4b7c-af61-fe5844fdc3d7")

      cy.typeIntoTerminal("{upArrow}")
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents["route.tsx"]
          .name,
      )

      // select the current file and the file below. There are three files in
      // this directory so two will be selected and one will be left
      // unselected
      cy.typeIntoTerminal("vk")
      cy.typeIntoTerminal("{control+s}")

      // telescope should be open now
      cy.contains("to Fuzzy Search")

      // search for some file content. This should match
      // ../../../test-environment/routes/posts.$postId/adjacent-file.txt
      cy.typeIntoTerminal("this")

      // some results should be visible
      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents[
          "adjacent-file.txt"
        ].name,
      )
      cy.contains("02c67730-6b74-4b7c-af61-fe5844fdc3d7")

      cy.contains(
        dir.contents.routes.contents["posts.$postId"].contents[
          "should-be-excluded-file.txt"
        ].name,
      ).should("not.exist")
    })
  })
})
