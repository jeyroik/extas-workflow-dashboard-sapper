<script context="module">
    export function preload({ params, query }) {
        return this.fetch('process.JSON_RPC__ENDPOINT', {
            method: 'POST',
            body: JSON.stringify({
                method: "workflow.schema.index",
                params: {
                    filter: {
                        name: {'$in':[query.name]}
                    },
                    expand:["schema.states", "schema.transitions"]
                }
            })
        }).then(r => r.json()).then(entities => {
            let schema = entities.result.items.pop();
            return { schema, query };
        });
    }
</script>

<svelte:head>
    <title>Схема - {schema.title} - {schema.description}</title>
</svelte:head>

<script>
    import { fabric } from "fabric"
    import { onMount, onDestroy } from 'svelte'
    import { goto } from '@sapper/app'
    import { deleteEntity } from '../../components/api.svelte';
    import { makeStateGroup, updateStateXY } from '../../components/drawing/States.svelte'
    import { makeTransition } from '../../components/drawing/Transitions.svelte'

    export let schema, query
    let stateCoords = {}
    let transitionsNames = []
    let transitionsByNames = {}
    let statesByNames = {}
    let activeState = null
    let colors = {
        '->': 'list-group-item-primary',
        '<-': 'list-group-item-success'
    }
    let dirs = {
        '->': '<svg style="color: blue" width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-arrow-right" fill="currentColor" xmlns="http://www.w3.org/2000/svg">\n' +
            '  <path fill-rule="evenodd" d="M1 8a.5.5 0 0 1 .5-.5h11.793l-3.147-3.146a.5.5 0 0 1 .708-.708l4 4a.5.5 0 0 1 0 .708l-4 4a.5.5 0 0 1-.708-.708L13.293 8.5H1.5A.5.5 0 0 1 1 8z"/>\n' +
            '</svg>',
        '<-': '<svg style="color: green" width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-arrow-left" fill="currentColor" xmlns="http://www.w3.org/2000/svg">\n' +
            '  <path fill-rule="evenodd" d="M15 8a.5.5 0 0 0-.5-.5H2.707l3.147-3.146a.5.5 0 1 0-.708-.708l-4 4a.5.5 0 0 0 0 .708l4 4a.5.5 0 0 0 .708-.708L2.707 8.5H14.5A.5.5 0 0 0 15 8z"/>\n' +
            '</svg>'
    }
    let canvas;

    schema.states.forEach(s => {
        statesByNames[s.name] = s
    })
console.log(schema)
    onDestroy(() => {
        canvas && canvas.dispose()
    })

    onMount(() => {
        canvas = new fabric.Canvas('canvas', {selection: false});
        canvas.setWidth(window.innerWidth*0.8);
        let states = schema.states
        let x = 120
        let y = 40
        let statesCircles = {}
        let selectedState = null;
        let onGroupOver = function (group) {
            canvas.renderAll()
        }
        let onGroupOut = function (group) {
            canvas.renderAll()
        }
        let onGroupMoving = function (group) {
            group.icon.left = group.left+group.getState().width
            group.icon.top = group.top+5
            canvas.renderAll()
        }

        states.forEach(state => {
            let stateGroup = makeStateGroup(state, x, y, onGroupOver, onGroupOut, onGroupMoving)
            stateGroup.on('selected', () => {
                stateGroup.linesFrom.forEach(l => {
                    if (transitionsByNames[l.name]) {
                        l.dir = '->'
                        transitionsNames.push(l)
                    }
                })
                stateGroup.linesTo.forEach(l => {
                    if (transitionsByNames[l.name]) {
                        l.dir = '<-'
                        transitionsNames.push(l)
                    }
                })
                transitionsNames = transitionsNames // to rise reactive
                activeState = stateGroup
                stateGroup.getState().strokeWidth = 4
                stateGroup.getState().set('dirty', true)
                stateGroup.allowClearTransitions = false

                stateGroup.icon.left = stateGroup.left+stateGroup.getState().width
                stateGroup.icon.top = stateGroup.top+5
                stateGroup.icon.set('dirty', true)

                selectedState = stateGroup

                canvas.add(stateGroup.icon)
                canvas.renderAll()
            })
            stateGroup.on('deselected', () => {
                transitionsNames = []
                activeState = null
                stateGroup.getState().strokeWidth = 1
                stateGroup.getState().set('dirty', true)
                stateGroup.allowClearTransitions = true
                stateGroup.clearTransitions()

                canvas.remove(stateGroup.icon)
                canvas.renderAll()
            })

            let iconObj;

            fabric.loadSVGFromString(
                '<svg width="1.5em" height="1.5em" viewBox="0 0 16 16" class="bi bi-node-plus-fill" fill="currentColor" xmlns="http://www.w3.org/2000/svg">\n' +
                '  <path fill-rule="evenodd" d="M11 13a5 5 0 1 0-4.975-5.5H4A1.5 1.5 0 0 0 2.5 6h-1A1.5 1.5 0 0 0 0 7.5v1A1.5 1.5 0 0 0 1.5 10h1A1.5 1.5 0 0 0 4 8.5h2.025A5 5 0 0 0 11 13zm.5-7.5a.5.5 0 0 0-1 0v2h-2a.5.5 0 0 0 0 1h2v2a.5.5 0 0 0 1 0v-2h2a.5.5 0 0 0 0-1h-2v-2z"/>\n' +
                '</svg>',
                (objects, options) => {
                    iconObj = fabric.util.groupSVGElements(objects, options);
                    iconObj.hoverCursor = 'pointer'
                    iconObj.selectable = true
                    iconObj.hasBorders = iconObj.hasControls = false
                    iconObj.lockMovementX = iconObj.lockMovementY = true
                    iconObj.on('selected', () => {
                        iconObj.stroke = '#a3c6c0'
                        iconObj.strokeWidth = 1
                        stateGroup.getState().strokeWidth = 4
                        stateGroup.getState().stroke = '#a3c6c0'
                        stateGroup.getState().set('dirty', true)
                        stateGroup.icon.left = stateGroup.left+stateGroup.getState().width
                        stateGroup.icon.top = stateGroup.top+5
                        stateGroup.icon.set('dirty', true)

                        selectedState = stateGroup

                        let targetState = null
                        let circle = new fabric.Circle({
                            radius: 5,
                            stroke: 'red',
                            strokeWidth: 1,
                            selectable: true,
                            hasBorders: false,
                            hasControls: false,
                            left: stateGroup.icon.getCenterPoint().x,
                            top: stateGroup.icon.getCenterPoint().y
                        })
                        let line = new fabric.Line([
                            stateGroup.icon.getCenterPoint().x+2,
                            stateGroup.icon.getCenterPoint().y,
                            stateGroup.icon.getCenterPoint().x+15,
                            stateGroup.icon.getCenterPoint().y,
                        ], {
                            hasControls: false,
                            hasBorders: false,
                            selectable: false,
                            fill: 'red',
                            strokeWidth: 2,
                            stroke: 'gray'
                        })
                        circle.on('moving', () => {
                            line.set({'x2':circle.getCenterPoint().x, 'y2':circle.getCenterPoint().y})
                            circle.setCoords()
                            canvas.forEachObject(obj => {
                                if (typeof obj.getState == 'undefined') {
                                    return
                                } else if (circle.intersectsWithObject(obj)) {
                                    obj.getState().strokeWidth = 4
                                    obj.getState().stroke = '#a3c6c0'
                                    obj.getState().set({'dirty':true})
                                    targetState = obj
                                    console.log('set target state')
                                } else {
                                    obj.getState().strokeWidth = 1
                                    obj.getState().stroke = '#666'
                                    obj.getState().set({'dirty':true})
                                    if ((targetState != null) && (targetState == obj)) {
                                        targetState = null
                                        console.log('unset target state')
                                    }
                                }
                            })
                        })

                        circle.on('moved', () => {
                            if (targetState != null) {
                                console.log('goto ' + '/transitions/new?state_from=' + stateGroup.stateName + '&' +
                                    'state_to=' + targetState.stateName + '&' +
                                    'schema_name=' + schema.name)
                                goto(
                                    '/transitions/new?state_from=' + stateGroup.stateName + '&' +
                                    'state_to=' + targetState.stateName + '&' +
                                    'schema_name=' + schema.name + '&' +
                                    'sample_name=none&' +
                                    'back_to_url=/schemas/view?name=' + schema.name
                                )
                            } else {
                                canvas.remove(circle)
                                canvas.remove(line)
                                canvas.remove(iconObj)
                            }
                        })

                        canvas.add(stateGroup.icon,line,circle)
                        canvas.renderAll()
                    })
                }
            );
            stateGroup.icon = iconObj
            statesCircles[state.name] = stateGroup
            stateCoords[state.name] = {x: x, y: y}

            let xy = updateStateXY(x, y)
            x = xy.x
            y = xy.y
        })

        let transitions = schema.transitions;

        transitions.forEach(t => {
            let tGroup = makeTransition(t, statesCircles, stateCoords, query)
            tGroup.afterConnectorMoved = () => canvas.renderAll()
            transitionsByNames[t.name] = true
            canvas.add(tGroup.lineStart, tGroup.lineEnd, tGroup.connector)
        })

        for (var [key,value] of Object.entries(statesCircles)) {
            canvas.add(value)
        }
    })

    function afterTransitionDeleted(item) {
        transitionsNames = transitionsNames.filter(t => t.name !== item.name)
        let stateGroup = canvas.getActiveObject()
        transitionsByNames[item.name] = false
        stateGroup.linesFrom.forEach((line, index) => {
            if (line.name === item.name) {
                let connector = line.connector
                let start = line.lineStart
                let end = line.lineEnd
                canvas.remove(connector)
                canvas.remove(start)
                canvas.remove(end)
                canvas.remove(line)
            }
        })
        stateGroup.linesTo.forEach((line, index) => {
            if (line.name === item.name) {
                let connector = line.connector
                let start = line.lineStart
                let end = line.lineEnd
                canvas.remove(connector)
                canvas.remove(start)
                canvas.remove(end)
                canvas.remove(line)
            }
        })
    }

    function afterStateDeleted(item) {
        activeState = null
        let stateGroup = canvas.getActiveObject()
        if (stateGroup.stateName === item.name) {
            canvas.remove(stateGroup)
        }
    }
</script>

<h2>Схема {schema.title} - {schema.description}</h2>

<div class="row">
    <div class="col-md-12">
        <ul>
            <li>Наведите на состояние курсор мыши, чтобы подсветить входящие и исходящие переходы.</li>
            <li>Кликните по состоянию, чтобы увидеть названия переходов.</li>
            <li>Кликните по состоянию и удерживайте, переместите состояние.</li>
        </ul>
    </div>
</div>
<div class="row">
    <div class="col-md-12">
        <button class="btn btn-primary" on:click={goto('/states/new?back_to_url=/schemas/view?name='+schema.name)}>Добавить состояние</button>
    </div>
</div>
<canvas id="canvas" height="850"></canvas>
<div class="row tlist">
    <div class="col-md-12">
        <ul class="list-group">
            {#if activeState !== null}
                <li class="list-group-item">
                    {activeState.stateTitle}: {activeState.stateDescription}
                    <br/>
                    {#if (activeState.linesTo.length === 0) && (activeState.linesFrom.length === 0)}
                        <span title="Удалить состояние" style="cursor: pointer" on:click={deleteEntity({name: activeState.stateName, src: activeState}, 'state', 'Состояние', item => (item.src.linesFrom.length > 0) || (item.src.linesTo.length > 0), 'Данное состояние используется в переходах. Сначала удалите переходы.', afterStateDeleted)}>
                            <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-trash" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                                <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
                                <path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4L4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
                            </svg>
                        </span>
                    {/if}
                    <span title="Изменить состояние" style="cursor: pointer" on:click={goto('/states/edit?name='+activeState.stateName + '&back_to_url=/schemas/view?name='+schema.name)}>
                        <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-pencil" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                          <path fill-rule="evenodd" d="M12.146.146a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1 0 .708l-10 10a.5.5 0 0 1-.168.11l-5 2a.5.5 0 0 1-.65-.65l2-5a.5.5 0 0 1 .11-.168l10-10zM11.207 2.5L13.5 4.793 14.793 3.5 12.5 1.207 11.207 2.5zm1.586 3L10.5 3.207 4 9.707V10h.5a.5.5 0 0 1 .5.5v.5h.5a.5.5 0 0 1 .5.5v.5h.293l6.5-6.5zm-9.761 5.175l-.106.106-1.528 3.821 3.821-1.528.106-.106A.5.5 0 0 1 5 12.5V12h-.5a.5.5 0 0 1-.5-.5V11h-.5a.5.5 0 0 1-.468-.325z"/>
                        </svg>
                    </span>
                </li>
            {/if}
            {#each transitionsNames as transition}
                <li class="list-group-item {colors[transition.dir]}">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">
                                {transition.title}

                            </h5>
                            <p class="card-text">
                                {#if transition.dir === '->'}
                                    {statesByNames[transition.state_from].title} {@html dirs[transition.dir]} {statesByNames[transition.state_to].title}
                                {:else}
                                    {statesByNames[transition.state_to].title} {@html dirs[transition.dir]} {statesByNames[transition.state_from].title}
                                {/if}
                            </p>

                            <span class="card-link" title="Удалить переход" style="cursor: pointer" on:click={deleteEntity({name: transition.name}, 'transition', 'Переход', item => false, 'Невозможно удалить переход', afterTransitionDeleted)} >
                                <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-trash" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                                    <path d="M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 .5-.5zm3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0V6z"/>
                                    <path fill-rule="evenodd" d="M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1v1zM4.118 4L4 4.059V13a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4H4.118zM2.5 3V2h11v1h-11z"/>
                                </svg>
                            </span>

                            <span class="card-link" title="Настроить переход" style="cursor: pointer" on:click={e => goto('/transitions/options?name=' + transition.name + '&back_to_url=/schemas/view?name='+schema.name)}>
                                <svg width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-gear-fill" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                                    <path fill-rule="evenodd" d="M9.405 1.05c-.413-1.4-2.397-1.4-2.81 0l-.1.34a1.464 1.464 0 0 1-2.105.872l-.31-.17c-1.283-.698-2.686.705-1.987 1.987l.169.311c.446.82.023 1.841-.872 2.105l-.34.1c-1.4.413-1.4 2.397 0 2.81l.34.1a1.464 1.464 0 0 1 .872 2.105l-.17.31c-.698 1.283.705 2.686 1.987 1.987l.311-.169a1.464 1.464 0 0 1 2.105.872l.1.34c.413 1.4 2.397 1.4 2.81 0l.1-.34a1.464 1.464 0 0 1 2.105-.872l.31.17c1.283.698 2.686-.705 1.987-1.987l-.169-.311a1.464 1.464 0 0 1 .872-2.105l.34-.1c1.4-.413 1.4-2.397 0-2.81l-.34-.1a1.464 1.464 0 0 1-.872-2.105l.17-.31c.698-1.283-.705-2.686-1.987-1.987l-.311.169a1.464 1.464 0 0 1-2.105-.872l-.1-.34zM8 10.93a2.929 2.929 0 1 0 0-5.86 2.929 2.929 0 0 0 0 5.858z"/>
                                </svg>
                            </span>

                        </div>
                    </div>
                </li>
            {/each}
        </ul>
    </div>
</div>

<style>
    .tlist{
        position: absolute;
        right: 100px;
        top: 20%;
        width: 300px;
    }
</style>