Memory = {
	current = {},
	previous = {},
}

function Memory.update()
	Memory.current.camera_fov = memory.readfloat(Addresses[Settings.address_source_index].camera_fov)
	Memory.current.camera_angle = memory.readword(Addresses[Settings.address_source_index].camera_angle)
	Memory.current.camera_transition_type = memory.readbyte(Addresses[Settings.address_source_index].camera_transition_type)
	Memory.current.camera_transition_progress = memory.readbyte(Addresses[Settings.address_source_index].camera_transition_progress)
	Memory.current.camera_x = memory.readfloat(Addresses[Settings.address_source_index].camera_x)
	Memory.current.camera_y = memory.readfloat(Addresses[Settings.address_source_index].camera_y)
	Memory.current.camera_z = memory.readfloat(Addresses[Settings.address_source_index].camera_z)
	Memory.current.camera_yaw = memory.readword(Addresses[Settings.address_source_index].camera_yaw)
	Memory.current.camera_pitch = memory.readword(Addresses[Settings.address_source_index].camera_pitch)
	Memory.current.holp_x = memory.readfloat(Addresses[Settings.address_source_index].holp_x)
	Memory.current.holp_y = memory.readfloat(Addresses[Settings.address_source_index].holp_y)
	Memory.current.holp_z = memory.readfloat(Addresses[Settings.address_source_index].holp_z)
	Memory.current.mario_facing_yaw = memory.readword(Addresses[Settings.address_source_index].mario_facing_yaw)
	Memory.current.mario_intended_yaw = memory.readword(Addresses[Settings.address_source_index].mario_intended_yaw)
	Memory.current.mario_h_speed = memory.readdword(Addresses[Settings.address_source_index].mario_h_speed)
	Memory.current.mario_v_speed = memory.readdword(Addresses[Settings.address_source_index].mario_v_speed)
	Memory.current.mario_x_sliding_speed = memory.readdword(Addresses[Settings.address_source_index].mario_x_sliding_speed)
	Memory.current.mario_z_sliding_sped = memory.readdword(Addresses[Settings.address_source_index].mario_z_sliding_speed)
	Memory.current.mario_x = memory.readdword(Addresses[Settings.address_source_index].mario_x)
	Memory.current.mario_y = memory.readdword(Addresses[Settings.address_source_index].mario_y)
	Memory.current.mario_z = memory.readdword(Addresses[Settings.address_source_index].mario_z)
	Memory.current.mario_object_pointer = memory.readdword(Addresses[Settings.address_source_index].mario_object_pointer)
	Memory.current.mario_object_effective = memory.readdword(Addresses[Settings.address_source_index].mario_object_effective)
	Memory.current.mario_action = memory.readdword(Addresses[Settings.address_source_index].mario_action)
	Memory.current.mario_action_arg = memory.readdword(Addresses[Settings.address_source_index].mario_action_arg)
	Memory.current.mario_f_speed = memory.readfloat(Addresses[Settings.address_source_index].mario_f_speed)
	Memory.current.mario_buffered = memory.readbyte(Addresses[Settings.address_source_index].mario_buffered)
	Memory.current.mario_global_timer = memory.readdword(Addresses[Settings.address_source_index].global_timer)
	Memory.current.rng_value = memory.readword(Addresses[Settings.address_source_index].rng_value)
	Memory.current.mario_animation = memory.readword(Addresses[Settings.address_source_index].mario_animation)
end

function Memory.update_previous()
	-- update previous values
	Memory.previous = Mupen_lua_ugui.internal.deep_clone(Memory.current)
end

function Memory.initialize()
	Memory.update()
	Memory.update_previous()
end