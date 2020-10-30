<script>
    import { goto } from '@sapper/app'
    import { create } from '../../components/api.svelte'
    import NewSample from '../../components/entities/NewSample.svelte'

    function createEntity(e) {
        let readyEntity = e.detail.entity
        create(readyEntity, 'entity.sample', 'Шаблон сущности', () => goto('/entities_samples'))
    }
</script>

<svelte:head>
    <title>Шаблоны сущности - Новый</title>
</svelte:head>

<h2>Создание шаблона сущности</h2>

<NewSample on:create-entity={createEntity}/>