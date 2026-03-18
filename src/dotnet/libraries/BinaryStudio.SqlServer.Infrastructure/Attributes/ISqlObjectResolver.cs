namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlObjectResolver<K,T>
        {
        T GetObject(K key);
        }
    }