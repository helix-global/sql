using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptProcedureDefinition<T> : SqlScriptCodeObject<T>
        where T: SqlProcedureDefinition
        {
        public Boolean IsForReplication { get { return Source.IsForReplication; }}
        public Int32? Number { get { return Source.Number; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptProcedureDefinition(IServiceProvider context,T source)
            : base(context, source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlProcedureDefinition))]
    internal sealed class SqlScriptProcedureDefinition : SqlScriptProcedureDefinition<SqlProcedureDefinition>
        {
        #region ctor{IServiceProvider,SqlProcedureDefinition}
        public SqlScriptProcedureDefinition(IServiceProvider context,SqlProcedureDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }