package main
import sa "core:container/small_array"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:testing"

ResourceMap :: distinct map[typeid]any
MAX_SYSTEMS :: 5
MAX_ENTITIES :: 2
StoredSystem :: ^System

Scheduler :: struct {
	systems:   sa.Small_Array(MAX_SYSTEMS, StoredSystem),
	resources: ResourceMap,
}

System :: struct {
	run: proc(self: ^System, resources: ^ResourceMap),
}

FunctionSystem :: struct($Input: typeid) {
	system: System,
	func:   Input,
}

add_resource :: proc(scheduler: ^Scheduler, resource: any) {
	fmt.assertf(scheduler != nil, "scheduler is nil")
	scheduler.resources[resource.id] = resource
}
add_system :: proc {
	add_system_0,
	add_system_1,
	add_system_2,
}

scheduler_run :: proc(scheduler: ^Scheduler) {
	fmt.assertf(scheduler != nil, "scheduler is nil")
	for system in sa.slice(&scheduler.systems) {
		fmt.assertf(system != nil, "system is nil")
		system.run(system, &scheduler.resources)
	}
}

destroy_scheduler :: proc(scheduler: ^Scheduler) {
	fmt.assertf(scheduler != nil, "scheduler is nil")
	delete(scheduler.resources)
}

destroy_ecs :: proc(ecs: ^ECS($N)) {
	fmt.assertf(ecs != nil, "ecs is nil")
	delete(ecs.components)
	delete(ecs.dispatch_table)
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

Handle :: struct {
	index: int,
	id:    int,
}

Components :: struct {}

FunctionComponents :: struct($N: int, $T: typeid) {
	components: Components,
	pool:       [N]T,
}

StoredComponents :: ^Components

ComponentsMap :: distinct map[typeid]StoredComponents

ComponentDispatch :: struct {
	add_to_resources: proc(val: StoredComponents, handle: Handle, scheduler: ^Scheduler)
}

ECS :: struct($N: int) {
	latest_id:        int,
	entity_top_count: int,
	entities:         [N]Handle,
	components:       ComponentsMap,
	dispatch_table:   map[typeid]ComponentDispatch,
	entity_free_list: [dynamic]int,
	scratch:          struct {
		all_entities: []Handle,
	},
}

register_component :: proc(ecs: ^ECS($N), $T: typeid) {
	fmt.assertf(ecs != nil, "ecs is nil")
	fmt.assertf(&ecs.components[T] == nil, "Already registered component")

	ecs.components[T] = make_component(N, T)
	
	ecs.dispatch_table[T] = ComponentDispatch{
		add_to_resources = proc(val: StoredComponents, handle: Handle, scheduler: ^Scheduler) {
			parent := cast(^FunctionComponents(N, T))val
			fmt.assertf(parent != nil, "parent is nil")
			// fmt.assertf(parent.pool[handle.index] != nil, "component is nil")
			add_resource(scheduler, parent.pool[handle.index])
			// add_resource(scheduler, &parent.pool[handle.index])
		}
	}
}

make_component :: proc($N: int, $T: typeid) -> StoredComponents {
	fc := new(FunctionComponents(N, T))
	return &fc.components
}

component_to_function_component :: proc(
	c: StoredComponents,
	$N: int,
	$T: typeid,
) -> ^FunctionComponents(N, T) {
	return cast(^FunctionComponents(N, T))c
}

add_component :: proc(ecs: ^ECS($N), handle: Handle, component: $T) {
	fmt.assertf(ecs != nil, "ecs is nil")
	parent := component_to_function_component(ecs.components[T], N, T)
	parent.pool[handle.index] = component
}

run_systems :: proc(ecs: ^ECS($N), scheduler: ^Scheduler) {
	fmt.assertf(ecs != nil, "ecs is nil")
	for handle in ecs.entities {
		for key, val in ecs.components {
			if dispatch, ok := ecs.dispatch_table[key]; ok {
				dispatch.add_to_resources(val, handle, scheduler)
			}
		}

		scheduler_run(scheduler)
	}
}

create_entity :: proc(ecs: ^ECS($N)) -> Handle {
	index := -1
	if len(ecs.entity_free_list) > 0 {
		index = pop(&ecs.entity_free_list)
	}

	if index == -1 {
		assert(ecs.entity_top_count + 1 < MAX_ENTITIES, "ran out of entities, increase size")
		ecs.entity_top_count += 1
		index = ecs.entity_top_count
	}

	entity := &ecs.entities[index]
	fmt.assertf(entity.index > -1, "entity index is not valid")
	entity.index = index
	entity.id = ecs.latest_id + 1
	ecs.latest_id = entity.id

	return entity^
}

Transform :: struct {
	x, y: f32,
}

main :: proc() {
	arena: vmem.Arena
	context.allocator = vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)
	position := [?]f32{0, 0}
	ecs := ECS(MAX_ENTITIES){}
	entity := create_entity(&ecs)
	register_component(&ecs, Transform)
	add_component(&ecs, entity, Transform{x = 69, y = 69})
	fmt.printf("%#v\n", ecs)

	scheduler: Scheduler

	// Create systems
	add_system(&scheduler, Transform, update_position)

	// Run them
	run_systems(&ecs, &scheduler)
}

update_position :: proc(transform: Transform) {
	fmt.println(transform)
}
