import moment from 'moment';
import Litepicker from 'litepicker';

const Hooks = {
    Flash: {
        mounted() {
            this.el.addEventListener('click', () => {
                this.closeFlash()
            });
        },
        closeFlash() {
            this.pushEvent("lv:clear-flash")
        }
    },
    Lang: {
        mounted() {
            this.el.addEventListener('change', (e) => {
                const parser = new URL(window.location);
                parser.searchParams.set('locale', e.target.value);
                window.location = parser.href;
            });
        }
    },
    ScrollOnUpdate: {
        mounted() {
            this.el.scrollIntoView();
        }
    },
    MultiSelect: {
        mounted() {
            const input = this.el.querySelector('input');
            const target = this.el.getAttribute('phx-target');
            const listName = this.el.dataset.list;

            input.addEventListener('keyup', (event) => {
                let value = event.target.value;
                if (event.key === ',') {
                    value.split(',').filter(v => v).forEach(item => {
                        const data = {
                            list: listName,
                            item: {
                                id: item,
                                title: item
                            },
                            type: 'add'
                        };
                        event.target.value = '';

                        if (!target) {
                            return this.pushEvent('multiselect', data);
                        }

                        this.pushEventTo(target, 'multiselect', data);
                    });
                }
            })
        }
    },
    DateRange: {
        mounted() {
            const org = this.el.dataset.innerText;

            new Litepicker({
                element: this.el,
                singleMode: false,
                tooltipText: {
                    one: 'day',
                    other: 'days'
                },
                setup: (picker) => {
                    picker.on('selected', (date1, date2) => {
                        // some action
                        const a = moment(date1.dateInstance);
                        const b = moment(date2.dateInstance);

                        this.el.innerText = `Period: ${a.format('YYYY-MM-DD')} - ${b.format('YYYY-MM-DD')}  (${b.diff(a, 'days')} days)`;

                        this.pushEvent('period', { start: date1.dateInstance, end: date2.dateInstance })
                    });
                },

            });

        }
    },
    TimeAgo: {
        date: 0,
        timer: null,
        mounted() {
            this.date = moment.utc(this.el.getAttribute('datetime'));
            this.updateTime();
        },
        destroyed() {
            clearTimeout(this.timer);
        },
        updateTime() {
            let nextUpdate = moment.utc().local().diff(this.date) / 1000;

            if (nextUpdate < 60) {
                nextUpdate = 1;
            } else if (nextUpdate < 60 * 60) {
                nextUpdate = 60;
            } else {
                nextUpdate = 60 * 60;
            }

            this.el.innerText = this.date.fromNow();
            this.timer = setTimeout(() => {
                this.updateTime();
            }, nextUpdate * 1000);
        }
    },
    ShortCut: {
        func: null,
        data: {},
        mounted() {
            this.data = {
                altKey: true,
                ctrlKey: false,
                key: this.el.dataset.key,
                targetEl: document.querySelector(this.el.dataset.targetEl),
            };

            this.keyDown = (event) =>  {
                if (event.altKey == this.data.altKey &&
                    event.ctrlKey == this.data.ctrlKey &&
                    `${event.key}` == `${this.data.key}`) 
                {
                    if (this.data.targetEl) {
                        this.data.targetEl.classList.add('shortcut__press');
                        this.data.targetEl.click();
                    }
                }
            }

            this.keyUp = (event) => {
                if (`${event.key}` == `${this.data.key}`) {
                    if (this.data.targetEl) {
                        this.data.targetEl.classList.remove('shortcut__press');
                    }
                }
            }

            document.addEventListener('keydown', this.keyDown);
            document.addEventListener('keyup', this.keyUp);
        },
        destroyed() {
            document.removeEventListener('keyup', this.keyUp);
            document.removeEventListener('keydown', this.keyDown);
        }
    }
}


export default Hooks;