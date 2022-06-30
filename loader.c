/* by Dreg */

#include <stdio.h>
#include <dlfcn.h>

int main(int argc, const char *argv[])
{
   void* handle  = NULL;
   void (*func)() = NULL;

   printf("Hello from loader by Dreg\n");

   handle = dlopen("./sharedlib.so", RTLD_NOW | RTLD_GLOBAL);
   if (handle == NULL)
   {
       fprintf(stderr, "Unable to open lib: %s\n", dlerror());
       return -1;
   }

   func = dlsym(handle, "ReflectiveLoader");
   if (func == NULL) {
       fprintf(stderr, "Unable to get symbol\n");
      return -1;
   }

   puts("calling to ReflectiveLoader....");
   func();

   return 0;
}
