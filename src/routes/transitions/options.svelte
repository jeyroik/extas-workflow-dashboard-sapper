<script context="module">
    export async function preload({ params, query }) {
        const transitionsResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.transition.index",
                params: {
                    expand:[
                        "transition.state_from",
                        "transition.state_to",
                        "schema",
                        "transition.dispatchers"
                    ],
                    context: {},
                    entity: {},
                    conditions: false,
                    filter: {name: {"$in":query.name}}
                }
            })
        })

        const dispatchersSamplesResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.transition.dispatcher.sample.index"
            })
        })

        const transitions = await transitionsResult.json().then(r => r.result.items);
        const dispatchersSamples = await dispatchersSamplesResult.json().then(r => r.result.items);
        const transition = transitions.pop()

        const entitiesResult = await this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.entity.index",
                params: {
                    filter: {schema_name: {"$in":[transition.schema_name]}}
                }
            })
        })

        const entities = await entitiesResult.json().then(r => r.result.items);
        const entity = entities.pop()

        return { transition, dispatchersSamples, entity, query };
    }
</script>

<script>
    import { v4 } from 'uuid'
    import { jsonRpc, saveEntity } from '../../components/api.svelte'
    import DispatchersSamples from '../../components/samples/DispatchersSamples.svelte'
    import Dispatcher from '../../components/dispatchers/Dispatcher.svelte'
    import DispatcherTabs from '../../components/dispatchers/DispatcherTabs.svelte'
    import Add from '../../components/samples/Add.svelte'
    export let transition, dispatchersSamples, entity, query
    let active = 'condition'
    let add = ''
    let currentSample = ''
    let tmp = JSON.parse(JSON.stringify(dispatchersSamples))
    let samples = {}

    tmp.forEach(s => {
        samples[s.name] = s
    })

    $: conditionsActive = active === 'condition' ? 'btn-primary' : ''
    $: validatorsActive = active === 'validator' ? 'btn-primary' : ''
    $: triggersActive = active === 'trigger' ? 'btn-primary' : ''

    function setActive(e){
        active = e.target.getAttribute('tab')
    }

    let ps = []
    for (var [name, options] of Object.entries(entity.parameters)) {
        ps.push(options)
    }
    entity.params = ps

    function createDispatcher(e) {
        for (let [name, s] of Object.entries(samples)) {
            if (s.name === currentSample) {
                s.transition_name = transition.name
                s.sample_name = s.name
                s.name = v4()
                s.type = active
                delete s.expand
                create(s)
                transition.dispatchers[active + 's'].push(s)
                transition.dispatchers[active + 's'] = transition.dispatchers[active + 's']
                currentSample = ''
                add = ''
            }
        }
    }

    function saveDispatcher(e) {
        let entity
        transition.dispatchers[active + 's'].forEach(d => {
            if (d.name == currentSample) {
                entity = d
            }
        })
        saveEntity(entity)
        currentSample = ''
    }

    function afterDeleteDispatcher(item){
        transition.dispatchers[active+'s'] = transition.dispatchers[active+'s'].filter(d => d.name != item.name)
    }

    async function create(sample) {
        jsonRpc(
            {
                method: "workflow.transition.dispatcher.create",
                params: {
                    data: sample
                }
            },
            () => {
                M.toast({html: 'Обработчик "' + sample.title + '" создан'});
            }
        );
    }
</script>

<div class="card">
    <div class="card-header fs2 tac">
            <span class="badge badge-info float-left">
                {transition.state_from.title}
                <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-arrow-right" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                    <path fill-rule="evenodd" d="M1 8a.5.5 0 0 1 .5-.5h11.793l-3.147-3.146a.5.5 0 0 1 .708-.708l4 4a.5.5 0 0 1 0 .708l-4 4a.5.5 0 0 1-.708-.708L13.293 8.5H1.5A.5.5 0 0 1 1 8z"/>
                </svg>
            </span>
            {transition.title}
            <span class="badge badge-info float-right">
                <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-arrow-right" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                    <path fill-rule="evenodd" d="M1 8a.5.5 0 0 1 .5-.5h11.793l-3.147-3.146a.5.5 0 0 1 .708-.708l4 4a.5.5 0 0 1 0 .708l-4 4a.5.5 0 0 1-.708-.708L13.293 8.5H1.5A.5.5 0 0 1 1 8z"/>
                </svg>
                {transition.state_to.title}
            </span>
    </div>
    <div class="card-body">
        <DispatcherTabs onActive={setActive} bind:transition={transition} bind:conditionsActive={conditionsActive} bind:validatorsActive={validatorsActive} bind:triggersActive={triggersActive}/>

        <div class="row">
            <div class="col-md-12">
                {#if active === 'condition'}
                    <div class="card">
                        <div class="card-header">
                            Данные проверки будут осуществляться при получении списка переходов
                            <Add title="Добавить условие" bind:add={add} addName="conditions"/>
                        </div>
                        {#if add === 'conditions'}
                            <DispatchersSamples entity={entity} createDispatcher={createDispatcher} bind:currentSample={currentSample} dispatchersSamples={dispatchersSamples} bind:samples={samples}/>
                        {/if}
                        <div class="card-body">
                            <div class="card-title">
                                Обработчики
                            </div>
                            {#each transition.dispatchers.conditions as item}
                                <Dispatcher afterDelete={afterDeleteDispatcher} typeRu="условие" bind:currentSample={currentSample} entity={entity} bind:item={item} dispatcher={saveDispatcher}/>
                            {/each}
                        </div>
                    </div>
                {:else if active === 'validator'}
                    <div class="card">
                        <div class="card-header">
                            Данные проверки будут осуществляться при выполнении переходов
                            <Add title="Добавить валидатор" bind:add={add} addName="validators"/>
                        </div>
                        {#if add === 'validators'}
                            <DispatchersSamples entity={entity} createDispatcher={createDispatcher} bind:currentSample={currentSample} dispatchersSamples={dispatchersSamples} bind:samples={samples}/>
                        {/if}
                        <div class="card-body">
                            <ul class="list-group">
                                {#each transition.dispatchers.validators as item}
                                    <Dispatcher afterDelete={afterDeleteDispatcher} typeRu="валидатор" bind:currentSample={currentSample} entity={entity} bind:item={item} dispatcher={saveDispatcher}/>
                                {/each}
                            </ul>
                        </div>
                    </div>
                {:else}
                    <div class="card">
                        <div class="card-header">
                            Данные операции будут осуществляться после выполнения переходов
                            <Add title="Добавить триггер" bind:add={add} addName="triggers"/>
                        </div>
                        {#if add === 'triggers'}
                            <DispatchersSamples entity={entity} createDispatcher={createDispatcher} bind:currentSample={currentSample} dispatchersSamples={dispatchersSamples} bind:samples={samples}/>
                        {/if}
                        <div class="card-body">
                            <ul class="list-group">
                                {#each transition.dispatchers.triggers as item}
                                    <Dispatcher afterDelete={afterDeleteDispatcher} typeRu="триггер" bind:currentSample={currentSample} entity={entity} bind:item={item} dispatcher={saveDispatcher}/>
                                {/each}
                            </ul>
                        </div>
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>

<style>
    .pointer {
        cursor: pointer
    }

    .fs2{
        font-size: 2em;
    }

    .tac{
        text-align: center;
    }
</style>