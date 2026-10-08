<template>
  <section class="p-reviews1" id="reviews">
    <div class="p-row">
      <p class="p-mono p-rev p-reviews2"><span class="p-reviews3">07</span>  <span>{{ t('nav.reviews') }}</span></p>
      <div>
        <h2 class="p-h2 p-rev p-reviews4"><span>{{ t('reviews.title') }}</span></h2>
        <p class="p-rev p-reviews5"><span>{{ t('reviews.lead') }}</span></p>
        <div class="p-reviews">
          <figure class="p-rev p-review p-reviews6">
            <div class="p-reviews7" aria-hidden="true">&ldquo;</div>
            <blockquote class="p-reviews8"><span>{{ t('reviews.r1') }}</span></blockquote>
            <figcaption class="p-reviews9">
              <span class="p-reviews10" aria-hidden="true">A</span>
              <span class="p-reviews11">
                <span class="p-reviews12"><span>{{ t('reviews.name') }}</span></span>
                <span class="p-reviews13"><span>{{ t('reviews.role') }}</span></span>
              </span>
            </figcaption>
          </figure>
          <figure class="p-rev p-review p-reviews14">
            <div class="p-reviews7" aria-hidden="true">&ldquo;</div>
            <blockquote class="p-reviews8"><span>{{ t('reviews.r2') }}</span></blockquote>
            <figcaption class="p-reviews9">
              <span class="p-reviews10" aria-hidden="true">B</span>
              <span class="p-reviews11">
                <span class="p-reviews12"><span>{{ t('reviews.name') }}</span></span>
                <span class="p-reviews13"><span>{{ t('reviews.role') }}</span></span>
              </span>
            </figcaption>
          </figure>
          <figure class="p-rev p-review p-reviews15">
            <div class="p-reviews7" aria-hidden="true">&ldquo;</div>
            <blockquote class="p-reviews8"><span>{{ t('reviews.r3') }}</span></blockquote>
            <figcaption class="p-reviews9">
              <span class="p-reviews10" aria-hidden="true">C</span>
              <span class="p-reviews11">
                <span class="p-reviews12"><span>{{ t('reviews.name') }}</span></span>
                <span class="p-reviews13"><span>{{ t('reviews.role') }}</span></span>
              </span>
            </figcaption>
          </figure>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
const { t } = useI18n()
</script>
