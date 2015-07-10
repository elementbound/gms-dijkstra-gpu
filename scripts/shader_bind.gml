//shader_bind(shader)
if(global.bound_shader!=argument0)
{
    shader_set(argument0);
    global.bound_shader=argument0;
    return 1;
}
return 0;