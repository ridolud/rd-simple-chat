<script setup lang="ts">
import { object, string, type InferType } from "yup";
import type { FormSubmitEvent } from "#ui/types";

const toast = useToast();
const props = defineProps<{ chat_id: string }>();
const emits = defineEmits(["success"]);

const schema = object({
  email: string().email().required("Required"),
});
type Schema = InferType<typeof schema>;
const state = reactive({
  email: undefined,
});

const client = useSupabaseClient();
const loading = useLoadingIndicator();
async function handleSubmit(event: FormSubmitEvent<Schema>) {
  loading.start();
  await new Promise((resolve) => setTimeout(resolve, 400));

  // Get user id
  let { data: new_member_user_id } = await client
    // @ts-ignore
    .rpc("get_user_id_by_email", { input_email: event.data.email });
  if (!new_member_user_id) {
    toast.add({ color: "red", title: "Email not registerd yet!" });
    loading.finish({ error: true });
    return;
  }

  // Add to member
  const { error } = await client
    .from("chat_members")
    //@ts-ignore
    .insert([{ chat_id: props.chat_id, user_id: new_member_user_id }])
    .select()
    .single();
  if (error) {
    const errorMessage =
      error.code == "23505" ? "Member already exist!" : error.message;
    toast.add({
      color: "red",
      title: "Error",
      description: errorMessage,
    });
    loading.finish({ error: true });
    return;
  }

  toast.add({
    title: "Success",
    description: "Member has been invited!",
  });
  emits("success");

  loading.finish();
}
</script>

<template>
  <UForm :state="state" :schema="schema" @submit="handleSubmit">
    <UFormGroup label="Invite Member" name="email">
      <div class="w-full flex items-center gap-2">
        <UInput class="w-full" placeholder="Email" v-model="state.email" />
        <UButton type="submit" :loading="loading.isLoading.value"
          >Invite</UButton
        >
      </div>
    </UFormGroup>
  </UForm>
</template>
