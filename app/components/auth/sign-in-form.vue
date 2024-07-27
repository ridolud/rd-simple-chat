<script setup lang="ts">
import { object, string, type InferType } from "yup";
import type { FormSubmitEvent } from "#ui/types";

const schema = object({
  email: string().email("Invalid email").required("Required"),
  password: string()
    .min(8, "Must be at least 8 characters")
    .required("Required"),
});

type Schema = InferType<typeof schema>;

const state = reactive({
  email: undefined,
  password: undefined,
});

const { auth } = useSupabaseClient();
const loading = ref(false);
async function onSubmit(event: FormSubmitEvent<Schema>) {
  loading.value = true;

  const { error } = await auth.signInWithPassword({
    email: event.data.email,
    password: event.data.password,
  });

  loading.value = false;

  if (error) {
    useToast().add({
      color: "red",
      title: "Invalid",
      description: error.message,
    });
  } else {
    useRouter().replace("/chats");
  }
}
</script>

<template>
  <UForm :state="state" :schema="schema" class="space-y-4" @submit="onSubmit">
    <UFormGroup label="Email" name="email">
      <UInput v-model="state.email" placeholder="Email" />
    </UFormGroup>

    <UFormGroup label="Password" name="password">
      <UInput v-model="state.password" type="password" placeholder="Password" />
    </UFormGroup>

    <UButton size="lg" block type="submit"> Sign In </UButton>
  </UForm>
  <div class="mt-4 text-center">
    <a class="text-sm text-primary" href="/auth/register">Register</a>
  </div>
</template>
