extends "res://scenes/ui/menu/base_menu_panel.gd"

onready var online = $"/root/Online"

onready var back_button = $"widgets/back_button"

onready var register_panel = $"widgets/register"
onready var register_button = $"widgets/register/register_button"
onready var register_description = $"widgets/register/description"

onready var online_panel = $"widgets/online"
onready var maps_panel = $"widgets/online/maps"
onready var maps_main = $"widgets/online/maps/main"
onready var upload_button = $"widgets/online/maps/main/upload_button"
onready var download_button = $"widgets/online/maps/main/download_button"
onready var maps_upload = $"widgets/online/maps/upload"
onready var confirm_upload_button = $"widgets/online/maps/upload/confirm_upload_button"
onready var change_button = $"widgets/online/maps/upload/change_button"
onready var upload_desc = $"widgets/online/maps/upload/description"
onready var upload_name = $"widgets/online/maps/upload/name"

var working = false

var selected_upload_map = null

func _ready():
    ._ready()
    self.upload_name.set_message_translation(false)
    self.upload_name.notification(NOTIFICATION_TRANSLATION_CHANGED)

func _on_back_button_pressed():
    if self.working:
        return
    self.audio.play("menu_back")
    if self.selected_upload_map != null:
        self.selected_upload_map = null
        self._select_panel()
    else:
        self.main_menu.close_online()

func _on_register_button_pressed():
    if self.working:
        return

    self.working = true
    self.audio.play("menu_click")
    self.register_description.set_text(tr("TR_REQUESTING_PLAYER_ID"))
    self.register_button.hide()
    self.back_button.hide()

    var result = self.online.request_player_id()
    if result is GDScriptFunctionState:
        result = yield(result, "completed")

    self.working = false
    if result == "ok":
        self.register_description.set_text(tr("TR_REQUESTING_PLAYER_SUCCESS"))
        yield(self.get_tree().create_timer(2), "timeout")
        self._select_panel()
    else:
        self.back_button.show()
        self.register_button.show()
        self.register_description.set_text(tr("TR_REQUESTING_PLAYER_FAIL"))
        yield(self.get_tree().create_timer(0.1), "timeout")
        self.register_button.grab_focus()




func show_panel():
    .show_panel()
    self._select_panel()

func _select_panel():
    self.back_button.show()
    if self.online.is_integrated():
        self._configure_online_panel()
    else:
        self._configure_registration_panel()

func _configure_online_panel():
    self.online_panel.show()
    self.register_panel.hide()
    self._configure_maps_panel()

func _configure_maps_panel():
    self.maps_panel.show()
    if self.selected_upload_map != null:
        self._configure_maps_upload_confirm_panel()
    else:
        self._configure_maps_upload_panel()


func _configure_maps_upload_panel():
    self.maps_main.show()
    self.maps_upload.hide()
    yield(self.get_tree().create_timer(0.1), "timeout")
    self.upload_button.grab_focus()


func _configure_maps_upload_confirm_panel():
    self.maps_main.hide()
    self.maps_upload.show()
    self.change_button.show()
    self.confirm_upload_button.show()
    self.upload_desc.set_text(tr("TR_SELECTED_MAP"))
    self.upload_name.set_text(self.selected_upload_map)
    self.confirm_upload_button.set_text(tr("TR_CONFIRM"))
    yield(self.get_tree().create_timer(0.1), "timeout")
    self.confirm_upload_button.grab_focus()

func _configure_registration_panel():
    self.online_panel.hide()
    self.register_panel.show()
    self.register_button.show()
    self.register_description.set_text(tr("TR_NEED_REGISTER"))

    yield(self.get_tree().create_timer(0.1), "timeout")
    self.register_button.grab_focus()

func _on_upload_button_pressed():
    self.audio.play("menu_click")
    self.main_menu.open_upload_picker()


func _on_download_button_pressed():
    self.audio.play("menu_click")


func _on_confirm_upload_button_pressed():
    if self.working:
        return

    self.working = true
    self.audio.play("menu_click")
    self.upload_desc.set_text(tr("TR_UPLOADING_WAIT"))
    self.confirm_upload_button.hide()
    self.change_button.hide()
    self.back_button.hide()

    var result = self.online.upload_map(self.selected_upload_map)
    if result is GDScriptFunctionState:
        result = yield(result, "completed")

    self.working = false
    self.back_button.show()
    if result != "":
        self.register_description.set_text(tr("TR_UPLOADING_SUCCESS"))
        self.upload_name.set_text(result)
        yield(self.get_tree().create_timer(0.1), "timeout")
        self.back_button.grab_focus()
    else:
        self.back_button.show()
        self.change_button.show()
        self.confirm_upload_button.show()
        self.confirm_upload_button.set_text(tr("TR_RETRY"))
        self.register_description.set_text(tr("TR_UPLOADING_FAIL"))
        yield(self.get_tree().create_timer(0.1), "timeout")
        self.confirm_upload_button.grab_focus()
