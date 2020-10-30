<script context="module">
    export async function preload({ params, query }) {
        const samplesResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.entity.sample.index"
            })
        });
        const schemasResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.schema.index"
            })
        });

        const schemas = await schemasResult.json().then(r => r.result.items);
        const samples = await samplesResult.json().then(r => r.result.items);

        return { samples, schemas };
    }
</script>

<script>
    import { v4 } from 'uuid'
    import { goto } from '@sapper/app'
    import { create } from '../../components/api.svelte'
    import NewSample from '../../components/entities/NewSample.svelte'

    export let samples, schemas
    let selectedSample
    let entityParameters = []
    let entity = {
        name: '',
        title: '',
        description: '',
        schema: '',
        sample_name: '',
        parameters: {}
    }

    function createEntity(e) {
        let entity = e.detail.entity
        entity.sample_name = selectedSample.name
        create(entity, 'entity', 'Сущность', () => goto('/entities'))
    }

    function applySample() {
        for(let [k,v] of Object.entries(selectedSample.parameters)) {
            v.id = v4()
            console.log(v.id + ' added')
            entityParameters.push(v)
        }
        entityParameters = entityParameters
    }
</script>

<svelte:head>
    <title>Сущности - Новая</title>
</svelte:head>

<h2>Создание сущности</h2>

<NewSample on:create-entity={createEntity} bind:entity={entity} bind:entityParameters={entityParameters}>
    <div class="form-group">
        <label for="sample_name">Шаблон</label>
        <select bind:value={selectedSample} on:change={applySample} id="sample_name" class="form-control form-control-sm">
            <option value="">Выберите шаблон</option>
            {#each samples as item}
                <option value={item} title="{item.description}">{item.title}</option>
            {/each}
        </select>
    </div>
    <div class="form-group">
        <label for="schema_name">Схема</label>
        <select required bind:value={entity.schema_name} id="schema_name" class="form-control form-control-sm">
            <option value="">Выберите схему</option>
            {#each schemas as item}
                <option value="{item.name}" title="{item.description}">{item.title}</option>
            {/each}
        </select>
    </div>
</NewSample>
