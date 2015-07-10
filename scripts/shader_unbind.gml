//shader_unbind()
if(global.bound_shader>=0)
{
    shader_reset();
    global.bound_shader=-1;
    return 1;
}
return 0;