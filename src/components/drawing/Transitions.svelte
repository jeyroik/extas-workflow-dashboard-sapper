<script context="module">
    import { fabric } from "fabric"

    function makeLine(coords, transition, color = 'gray', opacity = 0.2) {
        let line = new fabric.Line(coords, {
            fill: '',
            stroke: color,
            opacity: opacity,
            strokeWidth: 5,
            selectable: false,
            hasControls: false,
            hasBorders: false,
            evented: false,
            name: transition.name,
            title: transition.title,
            sourceColor: 'gray',
            sourceOpacity: 0.2
        })
        let lineStart = new fabric.Line([coords[0], coords[1], line.getCenterPoint().x, line.getCenterPoint().y], {
            hasControls: false,
            hasBorders: false,
            selectable: false,
            evented: false,
            stroke: color,
            strokeWidth: 5,
            opacity: opacity
        })
        let lineEnd =  new fabric.Line([line.getCenterPoint().x, line.getCenterPoint().y, coords[2], coords[3]], {
            hasControls: false,
            hasBorders: false,
            selectable: false,
            evented: false,
            stroke: color,
            strokeWidth: 5,
            opacity: opacity
        })
        let connector = new fabric.Circle({
            radius: 2,
            stroke: 'gray',
            strokeWidth: 1,
            left: line.getCenterPoint().x,
            top: line.getCenterPoint().y,
            hasControls: false,
            hasBorders: false,
            fill: 'gray',
            opacity: 0.2,
            hoverCursor: 'pointer'
        })

        connector.on('moving', () => {
            lineStart.set({'x2': connector.getCenterPoint().x, 'y2': connector.getCenterPoint().y})
            lineEnd.set({'x1': connector.getCenterPoint().x, 'y1': connector.getCenterPoint().y})

            if (typeof group.afterConnectorMoved !== 'undefined') {
                group.afterConnectorMoved(connector, group)
            }
        })

        let group = new fabric.Group([], {
            hasBorders: false,
            hasControls: false,
            name: transition.name,
            title: transition.title,
            state_from: transition.state_from,
            state_to: transition.state_to,
            selectable: false,
            connector: connector,
            lineStart: lineStart,
            lineEnd: lineEnd,
            sourceColor: 'gray',
            sourceOpacity: 0.2
        })

        return group
    }
    export function makeTransition(t, statesCircles, stateCoords, query) {
        let fromCenter = statesCircles[t.state_from].getCenterPoint()
        let toCenter = statesCircles[t.state_to].getCenterPoint()
        let coords = [
            fromCenter.x,
            fromCenter.y,
            toCenter.x,
            toCenter.y
        ]
        let sourceColor = 'gray'
        let opacity = 0.2
        if ((typeof query['created'] != 'undefined') && (query['created'] == t.name)) {
            sourceColor = '#20b2aa'
            opacity = 0.7
        }
        let line = makeLine(coords, t, sourceColor, opacity)
        statesCircles[t.state_from].linesFrom.push(line)
        statesCircles[t.state_to].linesTo.push(line)

        return line;
    }
</script>