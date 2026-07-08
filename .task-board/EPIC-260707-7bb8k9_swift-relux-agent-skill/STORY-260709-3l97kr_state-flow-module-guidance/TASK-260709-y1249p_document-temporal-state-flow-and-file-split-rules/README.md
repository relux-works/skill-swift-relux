# TASK-260709-y1249p: document-temporal-state-flow-and-file-split-rules

## Description
Update the swift-relux skill references so agents understand temporal state ownership and limits, Flow versus Saga responsibilities, allowed read-only business state dependencies in flows, reducer file naming, and namespace-based file splitting for models and other entities.

## Scope
Documentation-only update to swift-relux reference files. Cover temporal state purpose and weak ownership, the limitation that temporal state is not a stable Flow dependency for later reads, read-only BusinessState dependencies in flows/sagas, Flow versus Saga selection, reducer extraction into a namespace-named reducer file, and entity/model file splitting by namespace.

## Acceptance Criteria
1. Temporal State docs explain why it exists, how to attach it at SwiftUI container level, and why it must not be treated as a durable Flow dependency. 2. Core/module docs explain Flow versus Saga and that flows/sagas may read BusinessState dependencies but must mutate state only by dispatching actions. 3. Module convention docs explicitly require reducer code in a dedicated namespace-named reducer file and prohibit dumping unrelated models/entities into one file. 4. Existing namespace, naming, and module structure guidance remains consistent.
