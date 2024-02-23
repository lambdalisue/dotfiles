import { shallowMount } from '@vue/test-utils';
import View from './view.vue';

describe('View', () => {
  const wrapper = shallowMount(View);

  it('is a Vue instance', () => {
    expect(wrapper.isVueInstance()).toBeTruthy();
  });

  it('has an expected html structure', () => {
    expect(wrapper.html()).toMatchSnapshot();
  });
});
