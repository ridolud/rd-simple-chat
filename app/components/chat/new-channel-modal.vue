<script setup lang="ts">
import { object, string, type InferType } from "yup";
import type { FormSubmitEvent } from "#ui/types";

const emits = defineEmits(["close"]);

const schema = object({
  name: string().required("Required"),
});
type Schema = InferType<typeof schema>;
const state = reactive({
  name: undefined,
});

const store = useChatsStore();
const client = useSupabaseClient();
const loading = useLoadingIndicator();
async function handleSubmit(event: FormSubmitEvent<Schema>) {
  loading.start();
  const { data, error } = await client
    .from("chats")
    // @ts-ignore: Unreachable code error
    .insert([{ name: event.data.name }])
    .select()
    .single();
  loading.finish();

  if (data) {
    store.addChat(data);
    emits("close");
  }
}
</script>

<template>
  <UModal>
    <UCard>
      <template #header>
        <h1>New Channel</h1>
      </template>
      <UForm :state="state" :schema="schema" @submit="handleSubmit">
        <UFormGroup label="Name" name="name">
          <UInput v-model="state.name" placeholder="Channel's Name" />
        </UFormGroup>
        <div class="flex justify-end gap-2 mt-6">
          <UButton
            :disabled="loading.isLoading.value"
            color="white"
            @click.stop="() => emits('close')"
            >Cancel</UButton
          >
          <UButton type="submit" :loading="loading.isLoading.value"
            >Create</UButton
          >
        </div>
      </UForm>
    </UCard>
  </UModal>
</template>
