local UID = dofile(views_path .. "PianoRoll/UID.lua")
local PianoRoll = dofile(views_path .. "PianoRoll/PianoRoll.lua")

local selectionIndex = 0
local createdSheetCount = 0
local deletionIndex = nil

local controlHeight = 0.75
local top = 16 - controlHeight

local function SelectCurrent()
    PianoRollContext.current = PianoRollContext.all[selectionIndex]
    if PianoRollContext.current ~= nil then
        PianoRollContext.current:jumpTo(PianoRollContext.current.previewGT)
    end
end

return {
    RenderConfirmDeletionPrompt = function()
        if deletionIndex == nil then return false end

        local confirmationText = "[Confirm deletion]\n\nAre you sure you want to delete \"" .. PianoRollContext.current.name .. "\"?\nThis action cannot be undone."

        local theme = Styles.theme()
        local foregroundColor = theme.listbox_item.text[1]

        BreitbandGraphics.draw_text(
            grid_rect(0, top - 8, 8, 8),
            "center",
            "end",
            {},
            foregroundColor,
            theme.font_size * 1.2 * Drawing.scale,
            theme.font_name,
            confirmationText)


        if ugui.button({
            uid = UID.ConfirmationYes,
            rectangle = grid_rect(4, top, 2, controlHeight),
            text = 'Yes'
        }) then
            table.remove(PianoRollContext.all, selectionIndex)
            SelectCurrent()
            deletionIndex = nil
        end
        if ugui.button({
            uid = UID.ConfirmationNo,
            rectangle = grid_rect(2, top, 2, controlHeight),
            text = 'No'
        }) then
            deletionIndex = nil
        end

        return true
    end,
    Render = function()
        local theme = Styles.theme()
        local foregroundColor = theme.listbox_item.text[1]

        local availablePianoRolls = {}
        for i = 1, #PianoRollContext.all, 1 do
            availablePianoRolls[i] = PianoRollContext.all[i].name
        end
        availablePianoRolls[#availablePianoRolls + 1] = "Off"

        if #PianoRollContext.all == 0 then
            BreitbandGraphics.draw_text(
                grid_rect(0, 0, 8, 16),
                "center",
                "center",
                { aliased = not ugui.standard_styler.params.cleartype},
                foregroundColor,
                theme.font_size * 1.2 * Drawing.scale,
                theme.font_name,
                "No piano roll sheets available.\nCreate one to proceed.")
        else
            if availablePianoRolls[selectionIndex] == "Off" then
                BreitbandGraphics.draw_text(
                    grid_rect(0, 0, 8, 16),
                    "center",
                    "center",
                    { aliased = not ugui.standard_styler.params.cleartype },
                    foregroundColor,
                    theme.font_size * 1.2 * Drawing.scale,
                    theme.font_name,
                    "No piano roll sheet selected.\nSelect one to proceed.")
            end
        end

        local nextPianoRoll = ugui.carrousel_button(
            {
                uid = UID.SelectionSpinner,

                rectangle = grid_rect(3, top, 4, controlHeight),
                items = availablePianoRolls,
                selected_index = selectionIndex,
                is_enabled = #availablePianoRolls > 1
            }
        )

        if (ugui.button({
            uid = UID.Delete,

            rectangle = grid_rect(2, top, 1, controlHeight),
            text = "-",
            is_enabled = PianoRollContext.all[nextPianoRoll] ~= nil,
        })) then
            deletionIndex = selectionIndex
        end

        if ugui.button({
            uid = UID.AddPianoRoll,

            rectangle = grid_rect(7, top, 1, controlHeight),
            text = "+",
        }) then
            nextPianoRoll = #PianoRollContext.all + 1
            createdSheetCount = createdSheetCount + 1
            PianoRollContext.current = PianoRoll.new("Sheet " .. createdSheetCount)
            PianoRollContext.all[nextPianoRoll] = PianoRollContext.current
        end

        if selectionIndex ~= nextPianoRoll then
            selectionIndex = nextPianoRoll
            SelectCurrent()
        end
    end,
}