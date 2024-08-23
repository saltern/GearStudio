extends RichTextLabel


func link_clicked(link) -> void:
	var new_link: String = str(link)
	new_link = new_link.replace("{", "")
	new_link = new_link.replace("}", "")
	OS.shell_open(new_link)
