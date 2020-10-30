<script>
    import { jsonRpc } from '../../components/api.svelte';
    import { goto } from '@sapper/app'
    import { v4 } from 'uuid'

    let sample = {
        name: v4(),
        title: '',
        description: ''
    };

    async function create() {
        jsonRpc(
            {
                method: "workflow.state.sample.create",
                params: {
                    data: sample
                }
            },
            () => {
                let link = '/states_samples'
                goto(link)
                M.toast({
                    html: 'Шаблон "' + sample.title + '" создан',
                    classes: 'red'
                });
            }
        );
    }
</script>

<svelte:head>
    <title>Шаблоны состояний - Новый</title>
</svelte:head>

<h2>Создание шаблона состояния</h2>

<div class="row">
    <div class="col-md-12">
        <div class="form-group">
            <label for="title">Название</label>
            <input bind:value={sample.title} id="title" type="text" class="form-control form-control-sm">
        </div>
        <div class="form-group">
            <label for="description">Описание</label>
            <input bind:value={sample.description} id="description" type="text" class="form-control form-control-sm">
        </div>

        <div class="form-group">
            <button on:click={create} class="btn btn-primary">Создать</button>
        </div>
    </div>
</div>
