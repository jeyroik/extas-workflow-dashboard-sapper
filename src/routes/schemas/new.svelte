<script context="module">
    export async function preload({ params, query }) {
        const samplesResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.entity.sample.index"
            })
        });

        const samples = await samplesResult.json().then(r => r.result.items);

        return { samples };
    }
</script>
<script>
    import { v4 } from 'uuid'
    import { goto } from '@sapper/app'
    import { create } from '../../components/api.svelte'
    import NewSample from '../../components/entities/NewSample.svelte'

    export let samples
    let selectedSample

    function createSchema(e) {
        let readyEntity = e.detail.entity
        create(readyEntity, 'schema', 'Схема', createEntity)
    }

    function createEntity(schema) {
        if (typeof selectedSample == 'undefined') {
            selectedSample = {
                name: v4(),
                title: 'Auto-generated entity',
                description: 'You did not choose entity template, so the system set it to default',
                parameters: {}
            }
        }
        selectedSample.name = v4()
        selectedSample.schema_name = schema.name
        create(selectedSample, 'entity', 'Сущность (для схемы)', () => goto('/schemas'))
    }
</script>

<svelte:head>
    <title>Схемы - Новая</title>
</svelte:head>

<h2>Создание схемы</h2>

<NewSample on:create-entity={createSchema}>
    <div class="form-group">
        <label for="sample_name">Шаблон</label>
        <select required bind:value={selectedSample} id="sample_name" class="form-control form-control-sm">
            <option value="">Выберите шаблон сущности</option>
            {#each samples as item}
                <option value={item} title="{item.description}">{item.title}</option>
            {/each}
        </select>
    </div>
</NewSample>