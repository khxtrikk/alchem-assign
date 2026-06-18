import os
from typing import Any, Dict, List

from iii import InitOptions, Logger, register_worker
from transformers import AutoModelForCausalLM, AutoTokenizer

iii = register_worker(
    os.environ.get("III_URL", "ws://localhost:49134"),
    InitOptions(worker_name="inference-worker"),
)
logger = Logger()

# 1. Install dependencies
# pip install transformers accelerate gguf torch


model_id = "Qwen/Qwen2.5-0.5B-Instruct-GGUF"
gguf_file = "qwen2.5-0.5b-instruct-q8_0.gguf"

# 2. Load tokenizer and model from the GGUF file
tokenizer = AutoTokenizer.from_pretrained("Qwen/Qwen2.5-0.5B-Instruct")
model = AutoModelForCausalLM.from_pretrained(model_id, gguf_file=gguf_file)

# Qwen2.5 already has an excellent built-in chat template, so we don't need a custom one.

# 3. Run inference
def run_inference_handler(payload: Dict[str, str | List[Dict[str, Any]]]) -> Dict[str, Any]:
    # prompt = "Explain quantum entanglement in simple terms."
    messages = payload.get("messages", [])

    text = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
    inputs = tokenizer(text, return_tensors="pt").to(model.device)

    output = model.generate(**inputs, max_new_tokens=150, do_sample=True, temperature=0.7, repetition_penalty=1.2)
    result = tokenizer.decode(output[0][inputs["input_ids"].shape[-1]:], skip_special_tokens=True)

    print(result)

    # running_inference = iii.trigger(
    #     {
    #         "function_id": "inference::get",
    #         "payload": {"scope": "math", "key": "running_inference"},
    #     }
    # )
    # new_result = payload | {"messages": payload["messages"] + (running_inference or [])}
    # iii.trigger(
    #     {
    #         "function_id": "inference::set",
    #         "payload": {"scope": "math", "key": "running_inference", "value": new_result},
    #     }
    # )
    # result["running_inference"] = new_result
    return {"text": result}

# def add_handler(payload: dict) -> dict:
#     a = payload.get("a", 0)
#     b = payload.get("b", 0)
#     logger.info(f"math::add called in Python with a={a}, b={b}")
#     result = {"c": a + b}

#     # --- Uncomment after: iii worker add iii-state ---
#     running_total = iii.trigger(
#         {
#             "function_id": "state::get",
#             "payload": {"scope": "math", "key": "running_total"},
#         }
#     )
#     new_total = (running_total or 0) + result["c"]
#     iii.trigger(
#         {
#             "function_id": "state::set",
#             "payload": {"scope": "math", "key": "running_total", "value": new_total},
#         }
#     )
#     result["running_total"] = new_total

#     return result


# iii.register_function("math::add", add_handler)
iii.register_function("inference::run_inference", run_inference_handler)

print("Inference worker started - listening for calls")
