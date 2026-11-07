-- lambdalisue/vim-suda: reads and writes files that need root, asking for the sudo password inside Neovim;
-- `:w !sudo tee %` fails here, since sudo finds no terminal for its prompt. :SudaWrite writes the buffer as root,
-- :SudaRead [file] opens a file only root can read.
return {
	"lambdalisue/vim-suda",
	cmd = { "SudaRead", "SudaWrite" },
}
