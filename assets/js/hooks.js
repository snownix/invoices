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
        mounted(){
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

                        this.pushEvent('period', { start: date1.dateInstance, end: date2.dateInstance})
                    });
                  },
                  
              });
            
        }
    },
    SearchSelect: {
        mounted() {
            this.hidden = true;
            let list = this.el.querySelector(".dropdown-content");
            list.style.display = "none"
            this.addListeners()
        },
        updated() {
            if (this.hidden) {
                let list = this.el.querySelector(".dropdown-content");
                list.style.display = "none";
            }
            this.removeListeners()
            this.addListeners()
        },
        destroyed() {
            this.removeListeners()
        },
        addListeners() {
            let input = this.el.querySelector(".search-input");
            let toggleBtn = this.el.querySelector(".toggle-btn");
            let list = this.el.querySelector(".dropdown-content");

            this.focusEvt = input.addEventListener("focus", (evt) => {
                this.hidden = false;
                list.style.display = "block";
            })
            this.keyupEvt = input.addEventListener("keyup", (evt) => {
                this.hidden = false;
                list.style.display = "block";
                let value = evt.target.value;
                this.pushEventTo(this.el.getAttribute("phx-target"), "filter", value);
            })
            this.blurEvt = input.addEventListener("blur", (evt) => {
                list = this.el.querySelector(".dropdown-content");
                this.hidden = true;
                setTimeout(() => {
                    list.style.display = "none";                    
                }, 200);
            })
            this.clickEvt = toggleBtn.addEventListener("click", (evt) => {7
                this.hidden = !this.hidden;
                list.style.display = this.hidden ? "block" : "none";
            })
        },
        removeListeners() {
            removeEventListener("focus", this.focusEvt);
            removeEventListener("blur", this.blurEvt);
            removeEventListener("keyup", this.keyupEvt);
            removeEventListener("click", this.clickEvt);
        }
    }
}


export default Hooks;