-- Database Schema for Big Data ML/AI Image Processing System
-- Designed for scalability and future development

-- Users table to manage system users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Images table to store image metadata
CREATE TABLE IF NOT EXISTS images (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100),
    width INTEGER,
    height INTEGER,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'uploaded',
    INDEX idx_user_id (user_id),
    INDEX idx_status (status)
);

-- Processing tasks table to track ML/AI operations
CREATE TABLE IF NOT EXISTS processing_tasks (
    id SERIAL PRIMARY KEY,
    image_id INTEGER REFERENCES images(id) ON DELETE CASCADE,
    task_type VARCHAR(100) NOT NULL, -- e.g., 'classification', 'detection', 'segmentation'
    status VARCHAR(50) DEFAULT 'pending', -- pending, processing, completed, failed
    parameters JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    INDEX idx_image_id (image_id),
    INDEX idx_status (status),
    INDEX idx_task_type (task_type)
);

-- Results table to store ML/AI processing results
CREATE TABLE IF NOT EXISTS processing_results (
    id SERIAL PRIMARY KEY,
    task_id INTEGER REFERENCES processing_tasks(id) ON DELETE CASCADE,
    result_data JSONB NOT NULL, -- Flexible JSON storage for various result types
    confidence_score DECIMAL(5,4),
    processing_time_ms INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_task_id (task_id)
);

-- Models table to track ML models used
CREATE TABLE IF NOT EXISTS ml_models (
    id SERIAL PRIMARY KEY,
    model_name VARCHAR(200) NOT NULL,
    model_version VARCHAR(50) NOT NULL,
    model_type VARCHAR(100) NOT NULL, -- e.g., 'CNN', 'ResNet', 'YOLO'
    description TEXT,
    file_path VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(model_name, model_version),
    INDEX idx_model_type (model_type),
    INDEX idx_is_active (is_active)
);

-- Dataset table for training data management
CREATE TABLE IF NOT EXISTS datasets (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    data_path VARCHAR(500),
    dataset_size BIGINT,
    num_samples INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name)
);

-- Training jobs table for big data ML training
CREATE TABLE IF NOT EXISTS training_jobs (
    id SERIAL PRIMARY KEY,
    model_id INTEGER REFERENCES ml_models(id) ON DELETE SET NULL,
    dataset_id INTEGER REFERENCES datasets(id) ON DELETE SET NULL,
    job_name VARCHAR(200) NOT NULL,
    status VARCHAR(50) DEFAULT 'queued', -- queued, running, completed, failed
    hyperparameters JSONB,
    metrics JSONB, -- Store accuracy, loss, etc.
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_model_id (model_id)
);

-- Audit log for tracking system activities
CREATE TABLE IF NOT EXISTS audit_log (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id INTEGER,
    details JSONB,
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at),
    INDEX idx_action (action)
);

-- Create a view for recent processing statistics
CREATE OR REPLACE VIEW processing_statistics AS
SELECT 
    DATE(pt.created_at) as date,
    pt.task_type,
    COUNT(*) as total_tasks,
    SUM(CASE WHEN pt.status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
    SUM(CASE WHEN pt.status = 'failed' THEN 1 ELSE 0 END) as failed_tasks,
    AVG(pr.processing_time_ms) as avg_processing_time_ms
FROM processing_tasks pt
LEFT JOIN processing_results pr ON pt.id = pr.task_id
GROUP BY DATE(pt.created_at), pt.task_type;
