using System;
using System.Collections.Generic;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    /// <summary>
    /// Represents CREATE AGGREGATE statement.
    /// </summary>
    [SqlScriptObject(typeof(CreateAggregateStatement))]
    internal class SqlFragmentCreateAggregateStatement : SqlFragmentObject<CreateAggregateStatement>,ISqlScriptStatement
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
        [UsedImplicitly][Field] public SqlObjectIdentifier Name { get; }
        #endregion
        #region P:Name:SqlObjectIdentifier
        /// <summary>
        /// Aggregate parameters.
        /// </summary>
        [UsedImplicitly][Field] public IList<SqlFragmentProcedureParameter> Parameters { get; }
        #endregion

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
            return Name.ToString();
            }
        #endregion
        }
    }