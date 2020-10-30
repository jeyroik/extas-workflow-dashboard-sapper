<script>
    import { goto } from '@sapper/app'

    export let conditionsActive
    export let validatorsActive
    export let triggersActive
    export let transition
    export let onActive
</script>

<div class="row">
    <div class="col-md-12">
        <ul class="nav nav-tabs">
            <li class="nav-item">
                <span class="pointer nav-link {conditionsActive}" tab="condition" on:click={onActive}>
                    Условия
                    <span class="badge badge-light">{transition.dispatchers.conditions.length}</span>
                </span>
            </li>
            <li class="nav-item">
                <span class="pointer nav-link {validatorsActive}" tab="validator" on:click={onActive}>
                    Валидаторы
                    <span class="badge badge-light">{transition.dispatchers.validators.length}</span>
                </span>
            </li>
            <li class="nav-item">
                <span class="pointer nav-link {triggersActive}" tab="trigger" on:click={onActive}>
                    Триггеры
                    <span class="badge badge-light">{transition.dispatchers.triggers.length}</span>
                </span>
            </li>
        </ul>
        <span class="back animate__animated animate__jello animate__repeat-3" title="Перейти в схему" on:click={goto('/schemas/view?name='+transition.schema_name)}>
            <svg width="2em" height="2em" viewBox="0 0 16 16" class="bi bi-diagram-2" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
              <path fill-rule="evenodd" d="M6 3.5A1.5 1.5 0 0 1 7.5 2h1A1.5 1.5 0 0 1 10 3.5v1A1.5 1.5 0 0 1 8.5 6v1H11a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-1 0V8h-5v.5a.5.5 0 0 1-1 0v-1A.5.5 0 0 1 5 7h2.5V6A1.5 1.5 0 0 1 6 4.5v-1zM8.5 5a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5h-1a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h1zM3 11.5A1.5 1.5 0 0 1 4.5 10h1A1.5 1.5 0 0 1 7 11.5v1A1.5 1.5 0 0 1 5.5 14h-1A1.5 1.5 0 0 1 3 12.5v-1zm1.5-.5a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h1a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5h-1zm4.5.5a1.5 1.5 0 0 1 1.5-1.5h1a1.5 1.5 0 0 1 1.5 1.5v1a1.5 1.5 0 0 1-1.5 1.5h-1A1.5 1.5 0 0 1 9 12.5v-1zm1.5-.5a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h1a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5h-1z"/>
            </svg>
        </span>
    </div>
</div>

<style>
    .pointer {
        cursor: pointer
    }

    .back {
        position: absolute;
        right: 15px;
        top: -1px;
        cursor: pointer;
    }
</style>