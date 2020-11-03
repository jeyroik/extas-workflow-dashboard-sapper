<script>
    import ParameterSelect from './ParameterSelect.svelte'
    import ParameterInput from './ParameterInput.svelte'

    export let item
    export let dispatcher
    export let entity

    let valueInput
    let valueSelect
    let valueComponent = ParameterInput
    let valueSelectItems = []

    function setEntityParamValue(e){
        console.log(entity)
        let pName = e.target.value
        if (typeof entity.parameters[pName].allow !== 'undefined') {
            valueSelectItems = []
            let unknown = true
            entity.parameters[pName].allow.forEach(a => {
                valueSelectItems.push(a)

                if (valueInput.value === a.name) {
                    unknown = false
                }
            })
            if (unknown) {
                valueSelectItems.unshift({
                    name: valueInput.value,
                    title: valueInput.value,
                    description: valueInput.value
                })
            }
            valueSelectItems = valueSelectItems
            valueComponent = ParameterSelect
        } else {
            valueComponent = ParameterInput
        }
    }
</script>

<div class="card-body animate__animated animate__backInUp">
    <div class="form-group">
        <label for="title">Название обработчика</label>
        <input bind:value="{item.title}" type="text" class="form-control" id="title">
    </div>
    <div class="form-group">
        <label for="description">Описание обработчика</label>
        <input bind:value="{item.description}" type="text" class="form-control" id="description">
    </div>
    <div class="form-group">
        <label for="priority">Приоритет обработчика</label>
        <input bind:value="{item.priority}" type="number" class="form-control" id="priority">
    </div>

    {#each Object.entries(item.parameters) as [name, param]}
        <div class="form-group">
            <label for="{param.name}">
                {param.title}
                <span class="pointer" title="{param.description}">
                    <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-question-circle" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                      <path fill-rule="evenodd" d="M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/>
                      <path d="M5.255 5.786a.237.237 0 0 0 .241.247h.825c.138 0 .248-.113.266-.25.09-.656.54-1.134 1.342-1.134.686 0 1.314.343 1.314 1.168 0 .635-.374.927-.965 1.371-.673.489-1.206 1.06-1.168 1.987l.003.217a.25.25 0 0 0 .25.246h.811a.25.25 0 0 0 .25-.25v-.105c0-.718.273-.927 1.01-1.486.609-.463 1.244-.977 1.244-2.056 0-1.511-1.276-2.241-2.673-2.241-1.267 0-2.655.59-2.75 2.286zm1.557 5.763c0 .533.425.927 1.01.927.609 0 1.028-.394 1.028-.927 0-.552-.42-.94-1.029-.94-.584 0-1.009.388-1.009.94z"/>
                    </svg>
                </span>
            </label>
            {#if (typeof param['allowed'] !== 'undefined') && (param['allowed'].length > 0)}
                <select id="{param.name}" bind:value={item.parameters[name].value} class="form-control" >
                    {#each param['allowed'] as allowed}
                        <option value="{allowed.name}" title="{allowed.description}">{allowed.title}</option>
                    {/each}
                </select>
            {:else if param.name === 'field_name'}
                <select id="{param.name}" bind:value={item.parameters[name].value} class="form-control" on:change={setEntityParamValue}>
                    {#each entity.params as field}
                        <option value="{field.name}" title="{field.description}">{field.title}</option>
                    {/each}
                </select>
            {:else if param.name === 'field_value'}
                <svelte:component this={valueComponent} bind:this={valueInput} bind:value={item.parameters[name].value} items={valueSelectItems}/>
            {:else}
                <input bind:value={item.parameters[name].value} id="{param.name}" class="form-control"/>
            {/if}
        </div>
    {/each}
    <button on:click={dispatcher} class="btn btn-primary">Сохранить</button>
</div>

<style>
    .pointer {
        cursor: pointer
    }
</style>