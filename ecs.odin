package ecs
import sa "core:container/small_array"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:testing"

ResourceMap :: distinct map[typeid]any
MAX_SYSTEMS :: 5
StoredSystem :: ^System

Scheduler :: struct($N: int) {
	systems:   sa.Small_Array(N, StoredSystem),
	resources: ResourceMap,
}

System :: struct {
	run: proc(self: ^System, resources: ^ResourceMap),
}

FunctionSystem :: struct($Input: typeid) {
	system: System,
	func:   Input,
}

add_resource :: proc(scheduler: ^Scheduler($max_systems), resource: any) {
	fmt.assertf(scheduler != nil, "scheduler is nil")
	fmt.assertf(resource.data != nil, "resource is nil")
	scheduler.resources[resource.id] = resource
}
add_system :: proc {
	add_system_0,
	add_system_1,
	add_system_2,
}

scheduler_run :: proc(scheduler: ^Scheduler($make_systems)) {
	fmt.assertf(scheduler != nil, "scheduler is nil")
	for system in sa.slice(&scheduler.systems) {
		fmt.assertf(system != nil, "system is nil")
		system.run(system, &scheduler.resources)
	}
}

init_scheduler :: proc() -> Scheduler(MAX_SYSTEMS) {
	return Scheduler(MAX_SYSTEMS){}
}

destroy_scheduler :: proc(scheduler: ^Scheduler($max_systems)) {
	fmt.assertf(scheduler != nil, "scheduler is nil")
	delete(scheduler.resources)
}

make_system :: proc {
	make_system_0,
	make_system_1,
	make_system_2,
}

print_int :: proc(x: int) {
	fmt.println("Number:", x)
}

print_int_and_string :: proc(x: int, y: string) {
	fmt.println("Number:", x)
	fmt.println("String:", y)
}
print_int_and_string_2 :: proc(x: int, y: string) {
	fmt.println("Number 2:", x)
	fmt.println("String 2:", y)
}

hello_world :: proc() {
	fmt.println("Hello world!")
}

testing_vec :: proc(position: [2]f32, mut_position: ^[2]f32) {
	fmt.println(position)
	mut_position[0] += 10
	fmt.println(mut_position)
}
testing_vec_2 :: proc(position: [2]f32, mut_position: ^[2]f32) {
	fmt.println(position)
	mut_position[0] += 10
	fmt.println(mut_position)
}


@(test)
test_main :: proc(t: ^testing.T) {
	arena: vmem.Arena
	context.allocator = vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)
	position := [?]f32 {0,0}
	scheduler := init_scheduler()
	// // Create resource map
	add_resource(&scheduler, 42)
	add_resource(&scheduler, position)
	add_resource(&scheduler, &position)
	add_resource(&scheduler, "yoo")

	// Create systems
	add_system(&scheduler, hello_world)
	add_system(&scheduler, int, print_int)
	add_system(&scheduler, int, string, print_int_and_string)
	add_system(&scheduler, [2]f32, ^[2]f32, testing_vec)

	// Run them
	scheduler_run(&scheduler)
}

main :: proc() {
	arena: vmem.Arena
	context.allocator = vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)
	position := [?]f32 {0,0}
	scheduler := init_scheduler()
	// // Create resource map
	add_resource(&scheduler, 42)
	add_resource(&scheduler, position)
	add_resource(&scheduler, &position)
	add_resource(&scheduler, "yoo")

	// Create systems
	add_system(&scheduler, hello_world)
	add_system(&scheduler, int, print_int)
	add_system(&scheduler, int, string, print_int_and_string)
	add_system(&scheduler, int, string, print_int_and_string_2)
	add_system(&scheduler, [2]f32, ^[2]f32, testing_vec)
	add_system(&scheduler, [2]f32, ^[2]f32, testing_vec_2)

	// Run them
	for {
		scheduler_run(&scheduler)
	}
}
