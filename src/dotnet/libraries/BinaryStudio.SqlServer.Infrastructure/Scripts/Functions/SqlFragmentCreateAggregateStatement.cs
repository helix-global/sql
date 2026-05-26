using System;
using System.Collections.Generic;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    /// <summary>
    /// Represents CREATE AGGREGATE statement.
    /// </summary>
    [SqlScriptObject(typeof(CreateAggregateStatement))]
    internal class SqlFragmentCreateAggregateStatement : SqlFragmentObject<CreateAggregateStatement>,ISqlScriptStatement,ISqlAggregate
        {
        public String StatementPhrase { get { return "CREATE AGGREGATE"; }}
        #region P:
        /// <summary>
        /// Specifies the assembly/class to bind with the user-defined aggregate function.
        /// </summary>
        [UsedImplicitly][Field] public SqlFragmentAssemblyName AssemblyName { get; }
        #endregion
        #region P:Name:SqlObjectIdentifier
        /// <summary>
        /// Aggregate function name.
        /// </summary>
        [UsedImplicitly][Field(Source="Name")] public SqlObjectIdentifier QualifiedName { get; }
        #endregion
        #region P:Name:SqlObjectIdentifier
        /// <summary>
        /// Aggregate parameters.
        /// </summary>
        [UsedImplicitly][Field] public IList<SqlFragmentProcedureParameter> Parameters { get; }
        #endregion
        [UsedImplicitly][Field] public ISqlFragmentDataTypeReference ReturnType { get; }

        #region ctor{IServiceProvider,CreateAggregateStatement}
        public SqlFragmentCreateAggregateStatement(IServiceProvider context,CreateAggregateStatement source)
            : base(context,source)
            {
            return;
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return QualifiedName.ToString();
            }
        #endregion
        }
    }