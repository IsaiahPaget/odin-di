package ecs
import "core:fmt"
import sa "core:container/small_array"

make_system_0 :: proc(f: proc()) -> StoredSystem {
	fs := new(FunctionSystem(proc()))
	fs.func = f

	run_proc := proc(scheduler: ^System, resources: ^ResourceMap) {
		fmt.assertf(scheduler != nil, "scheduler is nil")
		fmt.assertf(resources != nil, "resources is nil")
		// cast back: the incoming pointer points to the `system` field inside FunctionSystem
		parent := cast(^FunctionSystem(proc()))scheduler // pointer reinterpretation
		fmt.assertf(parent != nil, "parent is nil")
		parent.func()
	}

	fs.system.run = run_proc
	ptr := &fs.system
	return ptr // return pointer to embedded System
}
make_system_1 :: proc($T1: typeid, f: proc(T1)) -> ^System {
    fs := new(FunctionSystem(proc(T1)));
    fs.func = f;

    run_proc := proc(self: ^System, resources: ^ResourceMap) {
        // cast back: the incoming pointer points to the `system` field inside FunctionSystem
        parent := cast(^FunctionSystem(proc(T1)))self; // pointer reinterpretation
		_1 := resources[T1].(T1)
        parent.func(_1);
    };

    fs.system.run = run_proc;
    return cast(StoredSystem) &fs.system; // return pointer to embedded System
}
make_system_2 :: proc($T1: typeid, $T2: typeid, f: proc(T1, T2)) -> ^System {
    fs := new(FunctionSystem(proc(T1, T2)));
    fs.func = f;

    run_proc := proc(self: ^System, resources: ^ResourceMap) {
        // cast back: the incoming pointer points to the `system` field inside FunctionSystem
        parent := cast(^FunctionSystem(proc(T1, T2)))self; // pointer reinterpretation
		_1 := resources[T1].(T1)
		_2 := resources[T2].(T2)
        parent.func(_1, _2);
    };

    fs.system.run = run_proc;
    return cast(StoredSystem) &fs.system; // return pointer to embedded System
}
add_system_0 :: proc(scheduler: ^Scheduler($max_systems), system: proc()) {
	fmt.assertf(scheduler != nil, "scheduler is nil")
	fmt.assertf(system != nil, "system is nil")
	sa.append(&scheduler.systems, make_system(system))
}
add_system_1 :: proc(scheduler: ^Scheduler($max_systems), $T1: typeid, system: proc(_: T1)) {
	fmt.assertf(scheduler != nil, "scheduler is nil")
	fmt.assertf(system != nil, "system is nil")
	sa.append(&scheduler.systems, make_system(T1, system))
}
add_system_2 :: proc(
	scheduler: ^Scheduler($max_systems),
	$T1, $T2: typeid,
	system: proc(_: T1, _: T2),
) {
	fmt.assertf(scheduler != nil, "scheduler is nil")
	fmt.assertf(system != nil, "system is nil")
	sa.append(&scheduler.systems, make_system(T1, T2, system))
}
