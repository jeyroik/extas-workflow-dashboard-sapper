<script>
    import DispatcherBody from './DispatcherBody.svelte'
    import { deleteEntity } from '../api.svelte'

    export let item
    export let dispatcher
    export let entity
    export let currentSample
    export let typeRu
    export let afterDelete
</script>

<div class="card pointer border-0" title="{item.description}" on:click={e => currentSample = item.name}>
    <div class="card-header alert-light">
        {item.title}: {item.description}
        <span class="card-link pointer float-right red" title="Удалить {typeRu}" style="cursor: pointer" on:click={deleteEntity({name: item.name}, 'transition.dispatcher', 'Обработчик перехода', item => false, 'Невозможно удалить переход', afterDelete)} >
            <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-trash" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
                <path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4L4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
            </svg>
        </span>
    </div>
    {#if currentSample === item.name}
        <DispatcherBody entity={entity} bind:item={item} dispatcher={dispatcher}/>
    {/if}
</div>

<style>
    .red {
        color: red;
    }

    .pointer {
        cursor: pointer
    }
</style>