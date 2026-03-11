namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlConstraint
        {
        SqlIdentifier Name { get; }
        SqlConstraintType Type { get; }
        }
    }