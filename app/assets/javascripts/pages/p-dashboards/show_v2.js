import Swiper from 'swiper';
import { isPhone } from 'helpers/mobile_detect';

let swipers = [];

pageLoad('dashboards_show', () => {
  if (!$('.p-dashboards-show .v2').length) { return; }
  reInitSwipers();
  $(document).on('resize:debounced orientationchange', reInitSwipers);
});

pageUnload('dashboards_show', () => {
  if (!$('.p-dashboards-show .v2').length) { return; }
  destroySwipers();

  $(document).off('resize:debounced orientationchange', reInitSwipers);
});

function reInitSwipers() {
  console.log('reInitSwipers');
  destroySwipers();

  if (isPhone()) {
    swipers.push(
      new Swiper('.db-updates', {
        slidesPerView: 'auto',
        slidesPerColumn: 2,
        spaceBetween: 30,
        wrapperClass: 'inner',
        slideClass: 'db-update'
      })
    );
  }
}

function destroySwipers() {
  swipers.forEach(swiper => swiper.destroy());
  swipers = [];
}
