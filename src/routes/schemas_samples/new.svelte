<script>
    import { goto } from '@sapper/app'
    import { create } from '../../components/api.svelte'
    import NewSample from '../../components/entities/NewSample.svelte'

    function createEntity(e) {
        let readyEntity = e.detail.entity
        create(readyEntity, 'schema.sample', 'Шаблон схемы', () => goto('/schemas_samples'))
    }
</script>

<svelte:head>
    <title>Шаблоны схемы - Новый</title>
</svelte:head>

<h2>Создание шаблона схемы</h2>

<NewSample on:create-entity={createEntity}/>