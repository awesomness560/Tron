extends Control
class_name ChatAutoload

##Used to manage console/text chat

##There are three important commands to keep in mind
##[code]chat.print_message()[/code] Is used to print messages with a few examples listed below
##[codeblock]
##c_a_t.print_message(c_a_t.col(Color.GREEN, "Hi!"))
##c_a_t.print_message(c_a_t.bold(c_a_t.col("#984447", "This is bold and red dummy text")))
##c_a_t.print_message(c_a_t.italic(c_a_t.crossed("This is italic and crossed dummy text")))
##c_a_t.print_message(c_a_t.col(Color.BLUE_VIOLET, c_a_t.underline("It is already " + c_a_t.timestamp() + "! A late time!")))
##[/codeblock]
##The other two important commands are [code]chat.register_command()[/code] and [code]chat.delete_command()[/code]


@export var chat : ConsoleAndTextchat ##A reference to the text chat node
