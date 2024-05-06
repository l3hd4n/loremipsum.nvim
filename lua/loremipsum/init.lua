local M = {}

-- Configuration par défaut
M.config = {
	words_per_line = 10,
	word_count = 50,
	min_lines_per_paragraph = 3,
	chance_of_newline = 0.3,
}

-- Fonction pour configurer le plugin
function M.setup(user_config)
	user_config = user_config or {}
	for key, value in pairs(user_config) do
		if M.config[key] ~= nil then
			M.config[key] = value
		end
	end
end

-- Fonction pour générer du Lorem Ipsum avec des retours de ligne
local function generate_lorem_ipsum(word_count, words_per_line, min_lines_per_paragraph, chance_of_newline)
	local lorem_ipsum_text =
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
	local words = {}
	for word in lorem_ipsum_text:gmatch("%w+") do
		table.insert(words, word)
	end

	local output = {}
	local line = {}
	local lines_this_paragraph = 0
	math.randomseed(os.time())

	for i = 1, word_count do
		table.insert(line, words[(i - 1) % #words + 1])
		if #line == words_per_line then
			table.insert(output, table.concat(line, " "))
			line = {}
			lines_this_paragraph = lines_this_paragraph + 1

			if lines_this_paragraph >= min_lines_per_paragraph and math.random() < chance_of_newline then
				table.insert(output, "")
				lines_this_paragraph = 0
			end
		end
	end

	if #line > 0 then
		table.insert(output, table.concat(line, " "))
	end

	return table.concat(output, "\n")
end

-- Fonction pour insérer le Lorem Ipsum dans le buffer courant
function M.insert_lorem_ipsum(word_count, min_lines_per_paragraph)
	word_count = word_count or M.config.word_count
	min_lines_per_paragraph = min_lines_per_paragraph or M.config.min_lines_per_paragraph

	local text =
		generate_lorem_ipsum(word_count, M.config.words_per_line, min_lines_per_paragraph, M.config.chance_of_newline)

	local buf = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(buf, line, line, false, vim.split(text, "\n"))
end

-- Création de la commande NeoVim
function M.create_command()
	vim.api.nvim_create_user_command(
		"LoremIpsumInsert", -- Nom de la commande
		function(opts)
			local args = vim.split(opts.args, " ")
			local word_count = tonumber(args[1])
			local min_lines_per_paragraph = tonumber(args[2])
			M.insert_lorem_ipsum(word_count, min_lines_per_paragraph)
		end,
		{
			nargs = "*", -- Permet de prendre un nombre variable d'arguments
			desc = "Insert Lorem Ipsum text with optional word count and minimum lines per paragraph",
		}
	)
end

-- Appelez create_command quelque part dans votre plugin, probablement après le setup
M.create_command()

return M
