using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlTriggerEvent))]
    internal sealed class SqlScriptTriggerEvent : SqlScriptCodeObject<SqlTriggerEvent>
        {
        public String Name { get { return Source.Name; }}

        #region ctor{IServiceProvider,SqlTriggerEvent}
        public SqlScriptTriggerEvent(IServiceProvider context,SqlTriggerEvent source)
            : base(context,source)
            {
            }
        #endregion
        }
    }