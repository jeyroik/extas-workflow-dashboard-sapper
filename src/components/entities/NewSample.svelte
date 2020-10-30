<script>
    import { v4 } from 'uuid'
    import { createEventDispatcher } from 'svelte';
    import Parameters from './Parameters.svelte'

    const dispatch = createEventDispatcher();

    export let entity = {
        name: '',
        title: '',
        description: '',
        parameters: {}
    }
    export let entityParameters = []

    entity.name = v4()

    function createEntity() {
        entityParameters.forEach(p => {
            entity.parameters[p.name] = {
                name: p.name,
                title: p.title,
                description: p.description
            }
        })
        dispatch('create-entity', {
            entity: entity
        });
    }
</script>

<h2>Создание сущности</h2>

<div class="row">
    <div class="col-md-12">
        <div class="form-group">
            <label for="title">Название</label>
            <input bind:value={entity.title} id="title" type="text" class="form-control form-control-sm">
        </div>
        <div class="form-group">
            <label for="description">Описание</label>
            <input bind:value={entity.description} id="description" type="text" class="form-control form-control-sm">
        </div>
        <slot></slot>
        <Parameters bind:parameters={entityParameters}/>
        <div class="form-group">
            <button on:click={createEntity} class="btn btn-primary">Создать</button>
        </div>
    </div>
</div>