import os
import psycopg2
from dotenv import load_dotenv

# Load MIA-DoD Environment Secrets
load_dotenv()

def recall_vector_memory(query_vector, limit=5):
    """
    Performs a ScaNN-powered vector search in AlloyDB for MIA-DoD Intel logs.
    """
    conn = psycopg2.connect(
        host=os.getenv("ALLOYDB_HOST"),
        database=os.getenv("ALLOYDB_DB"),
        user=os.getenv("ALLOYDB_USER"),
        password=os.getenv("ALLOYDB_PASS")
    )

    try:
        with conn.cursor() as cur:
            # The <=> operator is for cosine distance in pgvector
            # We use a ScaNN index for sub-second retrieval at scale
            search_query = """
                SELECT log_id, content, classification
                FROM intel_logs
                ORDER BY embedding_vector <=> %s
                LIMIT %s;
            """
            cur.execute(search_query, (query_vector, limit))
            results = cur.fetchall()
            return results
    finally:
        conn.close()

if __name__ == "__main__":
    print("MIA-DoD Memory Recall System Initialized...")
