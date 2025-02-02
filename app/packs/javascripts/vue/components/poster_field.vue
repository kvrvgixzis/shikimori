<template lang='pug'>
label.b-dropzone.block(
  ref='uploaderRef'
  data-hint='Перетаскивай сюда картинку размером от 450x700 пикселей;'
)
  input.hidden(
    type='file'
  )

.sizes.block(
  v-if='currentSrc'
)
.cc-2
  .c-column
    .cropper-container(
      v-show='currentSrc'
    )
      VueCropper(
        ref='vueCropperRef'
        :src='currentSrc'
        :aspect-ratio='aspectRatio'
        :auto-crop-area='1.0'
        :scalable='false'
        :movable='false'
        :rotatable='false'
        :zoomable='false'
        @crop='onCrop'
      )
    .no-image(
      v-if='!currentSrc'
    )
      img(
        :src='missingSrc'
      )
  .c-column
    p.m5
      | На странице аниме постер отображается целиком,
      | в каталоге аниме картинка отображается обрезанная.
    p(
      v-if='sizes.naturalWidth'
    ) Картинка: {{ sizes.naturalWidth }}x{{ sizes.naturalHeight }}
    // p(
    //   v-if='isDisabled'
    // )
    //   | Кроп: отключено
    //   .b-button.enable-crop(
    //     @click='enableCrop'
    //   ) Включить
    p(
      v-if='sizes.naturalWidth !== sizes.width || sizes.naturalHeight !== sizes.height'
    )
      | Кроп превью: {{ sizes.width }}x{{ sizes.height }}
      // .b-button.disable-crop(
      //   @click='disableCrop'
      // ) Отключить

    .b-button.clear.m15(
      @click='clear'
    ) Очистить
    .midheadline
      | Превью
    .preview(
      ref='templateRef'
      v-html='previewTemplateHTML'
    )
</template>

<script setup>
import { ref, reactive, watch, onMounted, nextTick } from 'vue';
import { debounce } from 'throttle-debounce';
import VueCropper from '@ballcat/vue-cropper';

import 'cropperjs/dist/cropper.css';

const props = defineProps({
  src: { type: String, required: false, default: '' },
  cropData: { type: Object, required: false, default: () => ({}) },
  posterId: { type: Number, required: false, default: null },
  previewTemplateHTML: { type: String, required: true },
  previewWidth: { type: Number, required: true },
  previewHeight: { type: Number, required: true }
});

const aspectRatio = props.previewWidth / props.previewHeight;
const missingSrc = '/assets/globals/missing_original.jpg';

const currentSrc = ref(props.src);
const vueCropperRef = ref(null);
const uploaderRef = ref(null);
const templateRef = ref(null);
const isDisabled = ref(false);
const currentPosterId = ref(props.posterId);

const sizes = reactive({
  naturalWidth: 0,
  naturalHeight: 0,
  width: 0,
  height: 0
});

let isInitialOnCrop = true;
const onCrop = e => {
  const canvasData = vueCropperRef.value.getCanvasData();

  sizes.naturalWidth = Math.ceil(canvasData.naturalWidth);
  sizes.naturalHeight = Math.ceil(canvasData.naturalHeight);
  sizes.width = Math.ceil(e.detail.width);
  sizes.height = Math.ceil(e.detail.height);

  if (props.cropData && isInitialOnCrop) {
    isInitialOnCrop = false;
    const { height, left, top, width } = props.cropData;

    vueCropperRef.value.setCropBoxData({
      height: scaleY(height),
      left: scaleX(left),
      top: scaleY(top),
      width: scaleX(width)
    });
  }

  syncPreviewImage();
};

defineExpose({
  posterId() {
    return currentPosterId.value;
  },
  cropData() {
    const data = vueCropperRef.value.getCropBoxData();

    return {
      height: descaleY(data.height),
      left: descaleX(data.left),
      top: descaleY(data.top),
      width: descaleX(data.width)
    };
  },
  toDataURI() {
    return currentPosterId.value ?
      null :
      vueCropperRef.value
        .crop()
        .clear()
        .getCroppedCanvas()
        .toDataURL();
  }
});

onMounted(async () => {
  const { FileUploader } = await import('@/views/file_uploader');

  new FileUploader(uploaderRef.value, {
    autoProceed: false,
    isResetAfterUpload: false,
    maxNumberOfFiles: 1,
    maxFileSize: 1024 * 1024 * 15
  })
    .on('upload:file:added', ({ target }, file) => onFileAdded(target, file));
});

function onFileAdded(uploader, uppyFile) {
  currentSrc.value = URL.createObjectURL(uppyFile.data);
  currentPosterId.value = null;
  uploader.uppy.reset();
}

function clear() {
  currentSrc.value = '';
  currentPosterId.value = null;
  syncPreviewImage();
}

const syncPreviewImage = debounce(100, () => {
  const img = templateRef.value.querySelector('img');
  const exportedDataUri = vueCropperRef.value.getCroppedCanvas()?.toDataURL();

  img.srcset = '';
  img.src = exportedDataUri || missingSrc;
});

function disableCrop() {
  isDisabled.value = true;

  vueCropperRef.value.setAspectRatio(0);
  vueCropperRef.value.disable();
}

function enableCrop() {
  isDisabled.value = false;

  vueCropperRef.value.enable();
  vueCropperRef.value.setAspectRatio(aspectRatio);
}

function scaleX(value) {
  return value * ratioX();
}

function descaleX(value) {
  return Math.round(value / ratioX());
}

function scaleY(value) {
  return value * ratioY();
}

function descaleY(value) {
  return Math.round(value / ratioY());
}

function ratioX() {
  const { naturalWidth, width } = vueCropperRef.value.getCanvasData();
  return width / naturalWidth;
}

function ratioY() {
  const { naturalHeight, height } = vueCropperRef.value.getCanvasData();
  return height / naturalHeight;
}
</script>

<style scoped lang='sass'>
.sizes
  font-size: 14px

.clear
  margin-top: 8px

.enable-crop,
.disable-crop
  margin-left: 8px

.cropper-container
  max-width: 100%
  width: 450px

::v-deep(.cropper-disabled)
  .cropper-view-box
    outline-color: rgba(#a630ff, 0.75)

  .cropper-line
    background-color: #a630ff

  .cropper-point
    background-color: #8e00fa

.preview
  width: 156px
</style>
