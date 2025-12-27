import { existsSync } from "fs";
import { join } from "path";

Bun.serve({
  port: 8080,
  fetch(req) {
    const url = new URL(req.url);
    let path = url.pathname;

    if (path === "/") {
      path = "/index.html";
    }

    const filePath = join("web", path);

    if (!existsSync(filePath)) {
      return new Response("Not found", { status: 404 });
    }

    return new Response(Bun.file(filePath), {
      headers: {
        "Cross-Origin-Opener-Policy": "same-origin",
        "Cross-Origin-Embedder-Policy": "require-corp",
      },
    });
  },
});

console.log("http://localhost:8080");

